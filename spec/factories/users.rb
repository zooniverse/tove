FactoryBot.define do
  factory :user do
    sequence :id
    login { "user#{ id }"}

    trait :admin do
      admin { true }
    end
  end
end
