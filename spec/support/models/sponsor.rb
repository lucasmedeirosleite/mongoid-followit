class Sponsor
  include Mongoid::Document
  include Mongoid::Followit::Follower

  field :name, type: String
end
