module Mongoid
  module Followit

    # Public: Module that add followee capabilities to a Mongoid model.
    # Important: A model can only be followed if it is a Followee one.
    #
    # Examples
    #
    #   class MyModel
    #     include Mongoid::Document
    #     include Mongoid::Followit::Followee
    #   end
    module Followee
      def self.included(base)
        base.class_eval do
          include Mongoid::Followit::Queryable
        end
      end

      # Public: Peform a query to return all Mongoid model followers.
      #
      # criteria(optional) - if true the return will be the type of
      #                      Mongoid::Criteria
      #
      # Examples
      #
      #   class Person
      #     include Mongoid::Document
      #     include Mongoid::Followee
      #
      #     field :name, type: String
      #     validates_uniqueness_of :name
      #   end
      #
      #   # => Person.find_by(name: 'Skywalker').followers
      #
      # Returns An Array of followers if criteria argument is false.
      # Returns A Mongoid::Criteria of followers if  criteria argument is true
      #         and followers are of only one type
      # Raises  HasTwoFollowerTypesError if criteria argument is true
      #         and model has two or more types of followers
      def followers(criteria: false)
        follow_collection_for_a(:follower, criteria: criteria)
      end
    end
  end
end
