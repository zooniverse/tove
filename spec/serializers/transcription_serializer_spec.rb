RSpec.describe TranscriptionSerializer, type: :serializer do
  let(:transcription) { build(:transcription) }

  let(:serializer) { described_class.new(transcription) }
  let(:serialized_data) { serializer.to_hash[:data][:attributes] }

  let(:collection_serializer) {
    described_class.new(transcription, { params: { is_collection: true }})
  }
  let(:serialized_collection) { collection_serializer.to_hash[:data][:attributes] }

  it 'serializes the expected attributes' do
    expect(serialized_data).to have_key(:workflow_id)
    expect(serialized_data).to have_key(:group_id)
    expect(serialized_data).to have_key(:status)
    expect(serialized_data).to have_key(:flagged)
    expect(serialized_data).to have_key(:updated_at)
    expect(serialized_data).to have_key(:updated_by)
  end

  it 'doesnt serialize text when is_collection param is true' do
    expect(serialized_collection).not_to have_key(:text)
  end
end
