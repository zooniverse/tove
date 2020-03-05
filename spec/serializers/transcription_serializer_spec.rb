RSpec.describe TranscriptionSerializer, type: :serializer do
  let(:transcription) { build(:transcription, locked_by: 'kar-aniyuki', lock_timeout: (DateTime.now + 1.hours)) }
  let(:serializer) { described_class.new(transcription) }
  let(:serialized_data) { serializer.to_hash[:data][:attributes] }

  it 'serializes the expected attributes' do
    expect(serialized_data).to have_key(:workflow_id)
    expect(serialized_data).to have_key(:group_id)
    expect(serialized_data).to have_key(:text)
    expect(serialized_data).to have_key(:status)
    expect(serialized_data).to have_key(:flagged)
    expect(serialized_data).to have_key(:updated_at)
    expect(serialized_data).to have_key(:updated_by)
  end

  context 'when transcription is locked and lock has not expired' do
    it 'serializes locked by username' do
      expect(serialized_data[:locked_by]).to eq(transcription.locked_by)
    end
  end

  context 'when lock has expired' do
    let(:unlocked_transcription) { build(:transcription, locked_by: 'kar-aniyuki', lock_timeout: (DateTime.now - 1.hours)) }
    let(:serializer) { described_class.new(unlocked_transcription) }
    let(:serialized_data) { serializer.to_hash[:data][:attributes] }

    it 'does not serialize locked by username' do
      expect(serialized_data[:locked_by]).to be_nil
    end
  end
end
