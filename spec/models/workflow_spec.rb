RSpec.describe Workflow, type: :model do
  context 'validating' do
    it 'requires a display name' do
      expect(build(:workflow, display_name: nil)).to_not be_valid
    end
  end
end
