FactoryGirl.define do
  factory :person do
    name { FFaker::Name.name }
    age { 20 + rand(10) }
  end
end

