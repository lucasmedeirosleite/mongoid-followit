class Role
  include Mongoid::Document
  include Mongoid::Followit::Follower
  include Mongoid::Followit::Followee

  field :name, type: String
end
