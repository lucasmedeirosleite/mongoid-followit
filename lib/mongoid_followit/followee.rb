module Mongoid
  module Followit
    module Followee
      def self.included(base)
        base.class_eval do
          include Mongoid::Followit::Queryable
        end
      end

      def followers(criteria: false)
        follow_collection_for_a(:follower, criteria: criteria)
      end
    end
  end
end
