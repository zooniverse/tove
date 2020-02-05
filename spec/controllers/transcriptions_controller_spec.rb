RSpec.describe TranscriptionsController, type: :controller do

  describe '#index' do
    let!(:transcription) { create(:transcription, status: 1) }
    let!(:another_transcription) { create(:transcription, workflow: transcription.workflow, status: 0) }
    let!(:separate_transcription) { create(:transcription, group_id: "HONK1", flagged: true, status: 2) }

    it_has_behavior "pagination" do
      let(:another) { another_transcription }
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'should render' do
      get :index
      expect(json_data.first).to have_type('transcription')
      expect(json_data.first).to have_attributes(:text, :status, :flagged)
      expect(json_data.first["id"]).to eql(transcription.id.to_s)
    end

    describe "filtration" do
      it 'filters by workflow_id' do
        get :index, params: { filter: { workflow_id_eq: separate_transcription.workflow_id } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(separate_transcription.id.to_s)
      end

      it 'filters by group_id' do
        get :index, params: { filter: { group_id_eq: separate_transcription.group_id } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(separate_transcription.id.to_s)
      end

      it 'filters by flagged' do
        get :index, params: { filter: { flagged_true: 1 } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(separate_transcription.id.to_s)
      end

      describe 'filters by id' do
        it 'filters by single id' do
          get :index, params: { filter: { id_eq: transcription.id } }
          expect(json_data.size).to eq(1)
          expect(json_data.first).to have_id(transcription.id.to_s)
        end

        it 'filters by multiple ids' do
          get :index, params: { filter: { id_in: "#{transcription.id},#{another_transcription.id}" } }
          expect(json_data.size).to eq(2)
        end
      end

      describe 'filters by status' do
        it 'filters by single status id' do
          get :index, params: { filter: { status_eq: another_transcription.status_before_type_cast } }
          expect(json_data.size).to eq(1)
          expect(json_data.first["attributes"]["status"]).to eq(another_transcription.status)
        end

        it 'filters by multiple status ids' do
          status_filter = "#{another_transcription.status_before_type_cast},#{separate_transcription.status_before_type_cast}"
          get :index, params: { filter: { status_in: status_filter } }
          expect(json_data.size).to eq(2)
        end

        it 'filters by status term' do
          get :index, params: { filter: { status_eq: another_transcription.status }}
          expect(json_data.size).to eq(1)
          expect(json_data.first["attributes"]["status"]).to eq(another_transcription.status)
        end

        it 'filters by multiple status terms' do
          status_filter = "#{another_transcription.status},#{separate_transcription.status}"
          get :index, params: { filter: { status_in: status_filter } }
          expect(json_data.size).to eq(2)
        end
      end
    end
  end

  describe '#show' do
    let!(:transcription) { create(:transcription) }

    it 'returns successfully' do
      get :show, params: { id: transcription.id }
      expect(response).to have_http_status(:ok)
    end

    it 'renders the requested transcription' do
      get :show, params: { id: transcription.id }
      expect(json_data).to have_id(transcription.id.to_s)
    end
  end

  describe '#update' do
    let!(:transcription) { create(:transcription) }
    let(:update_params) { { id: transcription.id, "data": { "type": "transcriptions", "attributes": { "flagged": 1 } } } }

    it 'updates the resource' do
      patch :update, params: update_params
      expect(transcription.reload.flagged).to be_truthy
    end

    context 'validates the input' do
      it 'is not valid JSON:API' do
        busted_params = { id: transcription.id, "data": { "nothing": "garbage" } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not exist' do
        busted_params = { id: 9999, "data": { "type": "transcriptions", "attributes": { "flagged": true } } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:not_found)
      end

      it 'is the wrong type' do
        busted_params = { id: transcription.id, "data": { "type": "projects", "attributes": { "flagged": true } } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'contains an invalid attribute' do
        busted_params = { id: transcription.id, "data": { "type": "transcriptions", "attributes": { "garf": true } } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#export' do
    let(:transcription) { create(:transcription, group_id: 'FROG_LADS_777' ) }
    let(:second_transcription) { create(:transcription, group_id: 'FROG_LADS_777' ) }
    let(:export_single_params) { { id: transcription.id } }
    let(:export_group_params) { { group_id: transcription.group_id } }

    before do
      transcription.files.attach(create_file_blob)
    end

    context 'exporting a single transcription' do
      it 'returns successfully' do
        get :export, params: export_single_params
        expect(response).to have_http_status(:ok)
      end

      it 'should have a response with content-type of application/zip' do
        get :export, params: export_single_params
        expect(response.header["Content-Type"]).to eq("application/zip")
      end
    end

    context 'exporting a transcription group' do
      it 'returns successfully' do
        get :export, params: export_group_params
        expect(response).to have_http_status(:ok)
      end

      it 'should have a response with content-type of application/zip' do
        get :export, params: export_group_params
        expect(response.header["Content-Type"]).to eq("application/zip")
      end
    end
  end
end
