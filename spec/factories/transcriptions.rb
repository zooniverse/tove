FactoryBot.define do
  factory :transcription do
    workflow
    group_id { "GROUP1A" }
    text { { structure: "tbd" } }
    status { 1 }
  end
end
