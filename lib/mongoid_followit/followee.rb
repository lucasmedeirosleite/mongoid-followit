module Mongoid
  module Followit
    module Followee

      def followers(criteria: false)
        grouped = Follow.where({
          followee_class: self.class,
          followee_id: self.id
        }).group_by { |f| f.follower_class }

        criteria ? followers_as_criteria(grouped) : followers_as_array(grouped)
      end

      private

      def followers_as_array(grouped)
        grouped.values.flatten.map do |follow|
          follow.follower_class.constantize.find(follow.follower_id)
        end
      end

      def followers_as_criteria(grouped)
        return Follow.none if grouped.empty?
        raise 'HasTwoFollowerTypesError' if grouped.length > 1
        follower_class = grouped.keys.first
        follower_ids = grouped[follower_class].map { |f| f.follower_id }
        follower_class.constantize.in(id: follower_ids)
      end
    end
  end
end
