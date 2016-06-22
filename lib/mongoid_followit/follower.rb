module Mongoid
  module Followit
    ##
    # Public: Module that add follower capabilities to a Mongoid model.
    #
    # Examples
    #
    #   class MyModel
    #     include Mongoid::Document
    #     include Mongoid::Followit::Follower
    #
    #     before_follow   :do_something_before
    #     before_unfollow :do_otherthing_before
    #
    #     after_follow   :do_something_after
    #     after_unfollow :do_otherthing_after
    #
    #   end
    module Follower
      def self.included(base)
        patch_class(base)
        generate_callbacks(base)
      end

      ##
      # Public: Creates Follow entries, for the Followee models, representing
      #         the models that are being followed.
      #
      # *followees - A collection of Followee models to be followed.
      #
      # Examples
      #
      #   # => person = Person.create!(name: 'Skywalker')
      #   # => profile = Profile.create!(name: 'Jedi')
      #   # => person.follow(profile)
      #
      # Returns nothing.
      # Raises  Runtime error if at least one of the models passed does not
      #         include the Mongoid::Followit::Followee module.
      def follow(*followees)
        perform_followable_action(:follow, followees)
      end

      ##
      # Public: Destroys the Follow entries, for the Followee models,
      #         making the Followee models to be unfollowed.
      #
      # *followees - A collection of Followee models to be unfollowed.
      #
      # Examples
      #
      #   # => person.unfollow(jedi, padawan)
      #
      # Returns nothing.
      # Raises  Runtime error if at least one of the models passed does not
      #         include the Mongoid::Followit::Followee module.
      def unfollow(*followees)
        perform_followable_action(:unfollow, followees)
      end

      ##
      # Public: Peform a query to return all Mongoid model
      #         that model is following.
      #
      # criteria(optional) - if true the return will be the type of
      #                      Mongoid::Criteria
      #
      # Examples
      #
      #   class Person
      #     include Mongoid::Document
      #     include Mongoid::Follower
      #
      #     field :name, type: String
      #     validates_uniqueness_of :name
      #   end
      #
      #   # => Person.find_by(name: 'Skywalker').followees
      #
      # Returns An Array of followees if criteria argument is false.
      # Returns A Mongoid::Criteria of followees if  criteria argument is true
      #         and followees are of only one type
      # Raises  HasTwoFolloweeTypesError if criteria argument is true
      #         and model has two or more types of followees
      def followees(criteria: false)
        follow_collection_for_a(:followee, criteria: criteria)
      end

      ##
      # Public: Peform a query to return the total of Mongoid model
      #         that model is following.
      #
      # Examples
      #
      #   # => user.follow(another_user)
      #   # => user.follow(different_user)
      #   # => user.followees_count
      #   # => 2
      #
      # Returns 0 if model is not following anybody.
      # Returns The total of models that the model is following.
      def followees_count
        follow_count_for_a(:followee)
      end

      private_class_method

      ##
      # Internal: Class method that configures the Mongoid model which has
      #           Mongoid::Followit::Follower model included.
      #
      # base - Mongoid model class which will be patched.
      #
      # PS: This method is used inside the .included method inside this Module.
      #
      # Returns nothing.
      def self.patch_class(base)
        base.class_eval do
          include Mongoid::Followit::Queryable
          include ActiveSupport::Callbacks
          define_callbacks :follow, :unfollow
          before_destroy :destroy_follow_data
        end
      end

      ##
      # Internal: Class method that generate callbacks
      #           for the #follow and #unfollow methods.
      #
      # base - Mongoid model class which will be patched.
      #
      # PS: This method is used inside the .included method inside this Module.
      #
      # Returns nothing.
      def self.generate_callbacks(base)
        %w(before after).each do |callback|
          %w(follow unfollow).each do |action|
            base.define_singleton_method("#{callback}_#{action}") do |*ar, &blo|
              set_callback(action.to_sym, callback.to_sym, *ar, &blo)
            end
          end
        end
      end

      private

      def perform_followable_action(action, followables)
        warn_non_unfollowee_existence(followables)
        run_callbacks(action) do
          followables.each do |followable|
            if :follow == action
              Follow.store_by!(followee: followable, follower: self)
            else
              Follow.destroy_by!(followee: followable, follower: self)
            end
          end
        end
      end

      def warn_non_unfollowee_existence(followees)
        unless followees.any? { |f| f.is_a?(Mongoid::Followit::Followee) }
          raise 'Object(s) must include a Mongoid::Followit::Followee'
        end
      end

      ##
      # Internal: Before destroy filter used to clean Mongoid model related
      #           data from the Follow collection.
      #
      #
      # PS: This method is used inside the .patch_class method
      #     inside this Module.
      #
      # Returns nothing.
      def destroy_follow_data
        Follow.destroy_followable_data(self)
      end
    end
  end
end
