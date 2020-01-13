RSpec.describe Transcription, type: :model do
  context 'validation' do
    it 'requires a workflow id' do
      expect(build(:transcription, workflow_id: nil)).to_not be_valid
    end

    it 'requires a group id' do
      expect(build(:transcription, group_id: nil)).to_not be_valid
    end

    it 'requires text' do
      expect(build(:transcription, text: nil)).to_not be_valid
    end

    it 'allows empty text' do
      expect(create(:transcription, text: {})).to be_valid
    end
  end
end
