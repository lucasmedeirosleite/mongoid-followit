module Mongoid
  module Followit
    module Follower
      def self.included(base)
        base.class_eval do
          include ActiveSupport::Callbacks
          define_callbacks :follow
        end

        [ 'before', 'after' ].freeze.each do |callback|
          base.define_singleton_method("#{callback}_follow") do |*args, &block|
            set_callback(:follow, callback.to_sym, *args, &block)
          end
        end

      end

      def follow(*followees)
        warn_non_unfollowee_existence followees
        followees.each do |followee|
          run_callbacks :follow do
            Follow.create!({
              followee_class: followee.class.to_s,
              followee_id: followee.id,
              follower_class: self.class.to_s,
              follower_id: self.id
            })
          end
        end
      end

      def unfollow
      end

      def followees
      end

      private

      def warn_non_unfollowee_existence(followees)
        unless followees.any? { |f| f.kind_of?(Mongoid::Followit::Followee) }
          raise 'Object(s) must include a Mongoid::Followit::Followee'
        end
      end
    end
  end
end
