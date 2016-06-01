FactoryGirl.define do

  factory(:group) do
    sequence(:name) { |i| "Group_#{i}" }

    trait :admin do
      name 'admin'
    end

    trait :sales do
      name 'sales'
    end
  end

end
