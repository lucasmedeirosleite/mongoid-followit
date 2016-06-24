module Mongoid
  module Followit
    ##
    # Internal: Module that add query capabilities Follower/Followee model.
    #
    # Examples
    #
    #   module Follower
    #     def self.included(base)
    #       base.class_eval do
    #         include Mongoid::Followit::Queryable
    #       end
    #     end
    #   end
    #
    #   module Followee
    #     def self.included(base)
    #       base.class_eval do
    #         include Mongoid::Followit::Queryable
    #       end
    #     end
    #   end
    module Queryable
      # Internal: Hash of options to build a query for the Follow collection.
      FOLLOW_OPTIONS = {
        followee: {
          class: :followee_class,
          id: :followee_id,
          exception: 'HasTwoFolloweeTypesError'
        },
        follower: {
          class: :follower_class,
          id: :follower_id,
          exception: 'HasTwoFollowerTypesError'
        }
      }.freeze

      def follow_collection_for_a(behavior, criteria:)
        grouped = Follow.where(query_options_for_a(behavior)).group_by { |f| f.send(FOLLOW_OPTIONS[behavior][:class]) }
        if criteria
          collection_as_criteria(behavior, grouped)
        else
          collection_as_array(behavior, grouped)
        end
      end

      def follow_count_for_a(behavior)
        options = query_options_for_a(behavior)
        Follow.where(options).count
      end

      def has_followable_link?(behavior, followable)
        Follow.find_by(query_options_for_a(behavior, followable)).present?
      rescue Mongoid::Errors::DocumentNotFound
        false
      end

      private

      def query_options_for_a(behavior, followable = nil)
        if(:followee == behavior)
          Follow.query_options(follower: self, followee: followable)
        else
          Follow.query_options(followee: self, follower: followable)
        end
      end

      def collection_as_criteria(behavior, grouped)
        case
        when grouped.empty?
          Follow.none
        when grouped.length > 1
          raise FOLLOW_OPTIONS[behavior][:exception]
        else
          ids = grouped[grouped.keys.first].map { |f| f.send(FOLLOW_OPTIONS[behavior][:id]) }
          grouped.keys.first.constantize.in(id: ids)
        end
      end

      def collection_as_array(behavior, grouped)
        behavior_class = FOLLOW_OPTIONS[behavior][:class]
        behavior_id = FOLLOW_OPTIONS[behavior][:id]
        grouped.values.flatten.map do |follow|
          follow.send(behavior_class).constantize.find(follow.send(behavior_id))
        end
      end
    end
  end
end
