module Mongoid
  module Followit
    module Follower
      def self.included(base)
        base.class_eval do
          include ActiveSupport::Callbacks
          define_callbacks :follow, :unfollow
          before_destroy :destroy_follow_data
        end

        ['before', 'after'].freeze.each do |callback|
          ['follow', 'unfollow'].freeze.each do |action|
            base.define_singleton_method("#{callback}_#{action}") do |*ar, &blo|
              set_callback(action.to_sym, callback.to_sym, *ar, &blo)
            end
          end
        end
      end

      def follow(*followees)
        warn_non_unfollowee_existence(followees)

        run_callbacks :follow do
          followees.each do |followee|
              Follow.find_or_create_by!({
                followee_class: followee.class.to_s,
                followee_id: followee.id,
                follower_class: self.class.to_s,
                follower_id: self.id
              })
          end
        end
      end

      def unfollow(*followees)
        warn_non_unfollowee_existence(followees)

        run_callbacks :unfollow do
          followees.each do |followee|
            Follow.find_by({
              followee_class: followee.class.to_s,
              followee_id: followee.id,
              follower_class: self.class.to_s,
              follower_id: self.id
            }).try(:destroy)
          end
        end
      end

      def followees(criteria: false)
        grouped = Follow.where({
          follower_class: self.class,
          follower_id: self.id
        }).group_by { |f| f.followee_class }

        criteria ? followees_as_criteria(grouped) : followees_as_array(grouped)
      end

      private

      def warn_non_unfollowee_existence(followees)
        unless followees.any? { |f| f.kind_of?(Mongoid::Followit::Followee) }
          raise 'Object(s) must include a Mongoid::Followit::Followee'
        end
      end

      def destroy_follow_data
        Follow.or({ followee_class: self.class.to_s, followee_id: self.id  },
                  { follower_class: self.class.to_s, follower_id: self.id  })
              .destroy_all
      end

      def followees_as_criteria(grouped)
        return Follow.none if grouped.empty?
        raise 'HasTwoFolloweeTypesError' if grouped.length > 1
        followee_class = grouped.keys.first
        followee_ids = grouped[followee_class].map { |f| f.followee_id }
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
