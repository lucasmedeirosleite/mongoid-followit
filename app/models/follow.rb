class Follow
  include Mongoid::Document
  include Mongoid::Timestamps

  field :followee_class, type: String
  field :followee_id, type: String
  field :follower_class, type: String
  field :follower_id, type: String
end
