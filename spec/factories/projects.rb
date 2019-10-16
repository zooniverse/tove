FactoryBot.define do
  factory :project do
    sequence(:slug){ |n| "user_#{ n }/project_#{ n }" }
  end
end
