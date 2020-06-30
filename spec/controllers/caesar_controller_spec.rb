RSpec.describe CaesarController, type: :controller do

  describe '#import' do
    let(:tagged_logger_double) { double }

    it 'instantiates an importer and calls #process' do
      expect(CaesarImporter).to receive(:new).and_call_original
      expect_any_instance_of(CaesarImporter).to receive(:process)
      post :import, as: :json, body: File.read(Rails.root.join("spec/fixtures/caesar_payload.json"))
    end

    it 'returns a 204 if processing is successful' do
      expect{
        post :import, as: :json, body: File.read(Rails.root.join("spec/fixtures/caesar_payload.json"))
      }
      .to change{Project.count}.by(1)
      .and change{Workflow.count}.by(1)
      .and change{Transcription.count}.by(1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns a 400 if there is an error' do
      expect(Raven).to receive(:capture_exception)
      post :import, as: :json, body: {just: 'garbage'}.to_json
      expect(response).to have_http_status(:bad_request)
    end

    it 'raises and logs an ActiveRecord::RecordNotUnique error on repeated imports' do
      expect(ActiveSupport::TaggedLogging)
        .to receive(:new)
        .with(Logger)
        .and_return(tagged_logger_double)

      allow(tagged_logger_double)
        .to receive(:tagged)
        .and_yield

      expect(tagged_logger_double).to receive(:warn)
      post :import, as: :json, body: File.read(Rails.root.join("spec/fixtures/caesar_payload.json"))
      post :import, as: :json, body: File.read(Rails.root.join("spec/fixtures/caesar_payload.json"))
      expect(response).to have_http_status(:no_content)
    end
  end
end
