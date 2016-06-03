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
            base.define_singleton_method("#{callback}_#{action}") do |*args, &block|
              set_callback(action.to_sym, callback.to_sym, *args, &block)
            end
          end
        end
      end

      def follow(*followees)
        warn_non_unfollowee_existence followees

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
        warn_non_unfollowee_existence followees

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

      def followees
      end

      private

      def warn_non_unfollowee_existence(followees)
        unless followees.any? { |f| f.kind_of?(Mongoid::Followit::Followee) }
          raise 'Object(s) must include a Mongoid::Followit::Followee'
        end
      end

      def destroy_follow_data
        Follow.or({ followee_class: self.class.to_s, followee_id: self.id  },
                  { follower_class: self.class.to_s, follower_id: self.id  }).destroy_all
      end
    end
  end
end
