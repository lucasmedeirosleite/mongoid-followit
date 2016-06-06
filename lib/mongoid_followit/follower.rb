module Mongoid
  module Followit
    module Follower
      def self.included(base)
        generate_callbacks(base)
        add_callbacks(base)
      end

      def follow(*followees)
        perform_followable_action(:follow, followees)
      end

      def unfollow(*followees)
        perform_followable_action(:unfollow, followees)
      end

      def followees(criteria: false)
        follow_collection_for_a(:followee, criteria: criteria)
      end

      private_class_method

      def self.add_callbacks(base)
        base.class_eval do
          include Mongoid::Followit::Queryable
          include ActiveSupport::Callbacks
          define_callbacks :follow, :unfollow
          before_destroy :destroy_follow_data
        end
      end

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

      def destroy_follow_data
        followee_params = { followee_class: self.class.to_s, followee_id: id  }
        follower_params = { follower_class: self.class.to_s, follower_id: id  }
        Follow.or(followee_params, follower_params).destroy_all
      end
    end
  end
end
