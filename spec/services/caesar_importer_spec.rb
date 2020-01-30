RSpec.describe CaesarImporter, type: :service do
  let(:transcription) { create(:transcription) }
  let(:args) {
    {
      id: transcription.id,
      reducible: {id: transcription.workflow.id, type: 'Workflow'},
      data: {},
      subject: {id: 9999}
    }
  }
  let(:importer) { described_class.new(args)}

  describe 'process' do
   xit 'fuckin processes' do
   end
  end
end
