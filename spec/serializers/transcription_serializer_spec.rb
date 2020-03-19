RSpec.describe TranscriptionSerializer, type: :serializer do
  let(:transcription) { build(:transcription) }

  let(:serializer) { described_class.new(transcription) }
  let(:data) { serializer.to_hash[:data][:attributes] }

  let(:serializer_include_text) {
    described_class.new(transcription, { params: { serialize_text: true }})
  }
  let(:data_with_text) { serializer_include_text.to_hash[:data][:attributes] }

  it 'serializes the expected attributes' do
    expect(data_with_text).to have_key(:workflow_id)
    expect(data_with_text).to have_key(:group_id)
    expect(data_with_text).to have_key(:status)
    expect(data_with_text).to have_key(:flagged)
    expect(data_with_text).to have_key(:updated_at)
    expect(data_with_text).to have_key(:updated_by)
    expect(data_with_text).to have_key(:text)
    expect(data_with_text).to have_key(:internal_id)
    expect(data_with_text).to have_key(:total_lines)
    expect(data_with_text).to have_key(:total_pages)
    expect(data_with_text).to have_key(:low_consensus_lines)
    expect(data_with_text).to have_key(:reducer)
    expect(data_with_text).to have_key(:parameters)
  end

  it 'doesnt serialize text when serialize_text is not set' do
    expect(data).not_to have_key(:text)
  end
end
