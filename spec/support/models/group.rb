class Group
  include Mongoid::Document
  include Mongoid::Followit::Followee

  field :name, type: String
end
