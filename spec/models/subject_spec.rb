RSpec.describe Subject, type: :model do
  context 'validation' do
    it 'requires a workflow' do
      expect(build(:subject, workflow: nil)).to_not be_valid
    end
  end
end
