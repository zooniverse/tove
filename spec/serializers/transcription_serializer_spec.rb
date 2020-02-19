RSpec.describe TranscriptionSerializer, type: :serializer do
  let(:transcription) { build(:transcription) }
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
end
