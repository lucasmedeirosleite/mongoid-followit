FactoryGirl.define do

  factory(:user) do
    sequence(:name) { |i| "User_#{i}" }
  end

end
