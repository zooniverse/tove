FactoryBot.define do
  factory :subject do
    workflow
    metadata { { internal_id: 'zetaone', group_id: 'GROUP1A' } }
  end
end
