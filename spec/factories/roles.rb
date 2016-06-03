FactoryGirl.define do

  factory(:role) do
    sequence(:name) { |i| "Role_#{i}" }
  end

end
