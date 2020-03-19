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

  context 'locking' do
    let!(:locked_transcription) { create(:transcription, locked_by: 'vegeta', lock_timeout: DateTime.now + 3.hours) }
    let(:current_user) { build :user, :admin }

    it 'confirms when a transcription is locked' do
      expect(locked_transcription.locked?).to be_truthy
    end

    it 'confirms when a transcription is unlocked' do
      locked_transcription.update(lock_timeout: DateTime.now - 1.hour)
      expect(Transcription.find(locked_transcription.id).locked?).to be_falsey
    end

    it 'confirms when a transcription is locked by another user' do
      expect(locked_transcription.locked_by_different_user? current_user.login).to be_truthy
    end
  end
end
