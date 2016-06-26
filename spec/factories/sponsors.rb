FactoryGirl.define do

  factory(:sponsor) do
    sequence(:name) { |i| "Sponsor_#{i}" }
  end

end
