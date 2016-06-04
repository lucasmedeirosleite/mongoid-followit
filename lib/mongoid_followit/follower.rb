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
        grouped = Follow.where(follower_class: self.class, follower_id: id)
                        .group_by(&:followee_class)
        criteria ? followees_as_criteria(grouped) : followees_as_array(grouped)
      end

      private_class_method

      def self.add_callbacks(base)
        base.class_eval do
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

      def followees_as_criteria(grouped)
        return Follow.none if grouped.empty?
        raise 'HasTwoFolloweeTypesError' if grouped.length > 1
        followee_class = grouped.keys.first
        followee_ids = grouped[followee_class].map(&:followee_id)
        followee_class.constantize.in(id: followee_ids)
      end

      def followees_as_array(grouped)
        grouped.values.flatten.map do |follow|
          follow.followee_class.constantize.find(follow.followee_id)
        end
      end
    end
  end
end
