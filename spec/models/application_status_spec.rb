RSpec.describe ApplicationStatus, type: :model do
  it "returns the commit id" do
    Rails.application.commit_id = 'example-id-3f8b092f285a'
    expect(build(:application_status).as_json).to eq({:commit_id => 'example-id-3f8b092f285a'})
  end
end
