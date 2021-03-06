module Mongoid
  module Followit
    ##
    # Public: Module that add followee capabilities to a Mongoid model.
    # Important: A model can only be followed if it is a Followee one.
    #
    # Examples
    #
    #   class MyModel
    #     include Mongoid::Document
    #     include Mongoid::Followit::Followee
    #   end
    module Followee
      def self.included(base)
        base.class_eval do
          include Mongoid::Followit::Queryable
        end
      end

      ##
      # Public: Check if model is followed by any other model.
      #
      # Examples
      #
      #   # => person.followed?
      #
      # Returns true if model is followed by other model(s).
      # Returns false if model is not followed by any model.
      def followed?
        Follow.where(followee_class: self.class.to_s, followee_id: id).count > 0
      end

      ##
      # Public: Peform a query to return all Mongoid model followers.
      #
      # criteria(optional) - if true the return will be the type of
      #                      Mongoid::Criteria
      #
      # Examples
      #
      #   class Person
      #     include Mongoid::Document
      #     include Mongoid::Followee
      #
      #     field :name, type: String
      #     validates_uniqueness_of :name
      #   end
      #
      #   # => Person.find_by(name: 'Skywalker').followers
      #
      # Returns An Array of followers if criteria argument is false.
      # Returns A Mongoid::Criteria of followers if  criteria argument is true
      #         and followers are of only one type
      # Raises  HasTwoFollowerTypesError if criteria argument is true
      #         and model has two or more types of followers
      def followers(criteria: false)
        follow_collection_for_a(:follower, criteria: criteria)
      end

      ##
      # Public: Check if model is followed by another model.
      #
      # followable - Mongoid::Document model to check
      #
      # Examples
      #
      #   # => person.followed_by?(followable)
      #
      # Returns true if model is followed by self.
      # Returns false if model is not followed by self.
      def followed_by?(followable)
        has_followable_link?(:follower, followable)
      end

      ##
      # Public: Peform a query to return the total of followers of
      #         the Mongoid model.
      #
      # Examples
      #
      #   # => user.follow(another_user)
      #   # => different_user.follow(another_user)
      #   # => another_user.followers_count
      #   # => 2
      #
      # Returns 0 if model has no followers.
      # Returns The total of followers of the model.
      def followers_count
        follow_count_for_a(:follower)
      end

      ##
      # Public: Peform a query to return all common Mongoid model followers.
      #
      # *followees - Mongoid::Followit::Followee models
      #
      # Examples
      #
      #   # => person.common_followers(a_person, another_person)
      #
      # Returns An Array of common followers.
      def common_followers(*followees)
        all_followers = [followers] + followees.map(&:followers)
        all_followers.inject(:&)
      end
    end
  end
end
