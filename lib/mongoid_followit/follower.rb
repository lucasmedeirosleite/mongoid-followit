module Mongoid
  module Followit
    module Follower

      def follow(*followees)
        check_if_has_any_non_unfollowee followees
        followees.each do |followee|
          Follow.create!({
            followee_class: followee.class.to_s,
            followee_id: followee.id,
            follower_class: self.class.to_s,
            follower_id: self.id
          })
        end
      end

      def unfollow
      end

      def followees
      end

      private

      def check_if_has_any_non_unfollowee(followees)
        unless followees.any? { |f| f.kind_of?(Mongoid::Followit::Followee) }
          raise 'Object(s) must include a Mongoid::Followit::Followee'
        end
      end

    end
  end
end
