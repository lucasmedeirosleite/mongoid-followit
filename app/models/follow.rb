class Follow
  include Mongoid::Document
  include Mongoid::Timestamps

  field :followee_class, type: String
  field :followee_id, type: String
  field :follower_class, type: String
  field :follower_id, type: String

  def self.store_by!(followee:, follower:)
    find_or_create_by!({
      followee_class: followee.class.to_s,
      followee_id: followee.id,
      follower_class: follower.class.to_s,
      follower_id: follower.id })
  end

  def self.destroy_by!(followee:, follower:)
    find_by({
      followee_class: followee.class.to_s,
      followee_id: followee.id,
      follower_class: follower.class.to_s,
      follower_id: follower.id })
    .try(:destroy)
  end
end
