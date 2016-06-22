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
          opposite_class: :follower_class,
          opposite_id: :follower_id,
          class: :followee_class,
          id: :followee_id,
          exception: 'HasTwoFolloweeTypesError'
        },
        follower: {
          opposite_class: :followee_class,
          opposite_id: :followee_id,
          class: :follower_class,
          id: :follower_id,
          exception: 'HasTwoFollowerTypesError'
        }
      }.freeze

      def follow_collection_for_a(behavior, criteria:)
        options = query_options_for_a(behavior)
        group_class = FOLLOW_OPTIONS[behavior][:class]
        grouped = Follow.where(options).group_by { |f| f.send(group_class) }
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

      private

      def query_options_for_a(behavior)
        options_class = FOLLOW_OPTIONS[behavior][:opposite_class]
        options_id = FOLLOW_OPTIONS[behavior][:opposite_id]
        {
          options_class => self.class,
          options_id => id
        }
      end

      def collection_as_criteria(behavior, grouped)
        return Follow.none if grouped.empty?
        raise FOLLOW_OPTIONS[behavior][:exception] if grouped.length > 1
        klazz = grouped.keys.first
        ids = grouped[klazz].map { |f| f.send(FOLLOW_OPTIONS[behavior][:id]) }
        klazz.constantize.in(id: ids)
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
