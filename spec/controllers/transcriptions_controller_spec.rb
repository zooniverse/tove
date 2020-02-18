RSpec.describe TranscriptionsController, type: :controller do
  let(:admin_user) { create :user, :admin }
  before { allow(controller).to receive(:current_user).and_return admin_user }

  describe '#index' do
    let!(:transcription) { create(:transcription, status: 1) }
    let!(:another_transcription) { create(:transcription, workflow: transcription.workflow, status: 0) }
    let!(:separate_transcription) { create(:transcription, group_id: "HONK1", flagged: true, status: 2) }

    it_has_behavior "pagination" do
      let(:another) { another_transcription }
    end

    describe 'roles' do
      before { allow(controller).to receive(:current_user).and_return user }

      context 'without any roles' do
        let(:user) { create(:user, roles: {} )}
        it "returns return an empty response" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(json_data.size).to eq(0)
        end
      end

      context 'as an admin' do
        let(:user) { create(:user, :admin) }
        it 'returns the full scope' do
          get :index
          expect(response).to have_http_status(:ok)
          expect(json_data.size).to eq(3)
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: {transcription.workflow.project.id => ['tester']}) }
        it 'returns the authorized workflow' do
          get :index
          expect(response).to have_http_status(:ok)
          expect(json_data.first).to have_type('transcription')
          expect(json_data.first).to have_attributes(:text, :status, :flagged)
          expect(json_data.first["id"]).to eql(transcription.id.to_s)
          expect(json_data.size).to eq(2)
        end
      end
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

    describe 'roles' do
      before do
        allow(controller).to receive(:current_user).and_return user
        get :show, params: { id: transcription.id }
      end

      context 'without any roles' do
        let(:user) { create(:user, roles: {} )}
        it "returns a 403" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'as an admin' do
        let(:user) { create(:user, :admin) }
        it 'returns the full scope' do
          expect(response).to have_http_status(:ok)
          expect(json_data).to have_id(transcription.id.to_s)
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: {transcription.workflow.project.id => ['tester']}) }
        it 'returns the authorized workflow' do
          expect(response).to have_http_status(:ok)
          expect(json_data["id"]).to eql(transcription.id.to_s)
        end
      end
    end
  end

  describe '#update' do
    let!(:transcription) { create(:transcription) }
    let(:update_params) { { id: transcription.id, "data": { "type": "transcriptions", "attributes": { "flagged": 1 } } } }

    it 'updates the resource' do
      patch :update, params: update_params
      expect(transcription.reload.flagged).to be_truthy
    end

    context 'when transcription status changes' do
      context 'when a transcription is approved' do
        it 'attaches 4 data files to the transcription' do
          update_params[:data][:attributes][:status] = 'approved'
          patch :update, params: update_params
          expect(transcription.files.count).to eq(4)
        end
      end

      context 'when a transcription is unapproved' do
        it 'removes attached data files from storage' do
          update_params[:data][:attributes][:status] = 'ready'
          patch :update, params: update_params
          expect(transcription.files.attached?).to be_falsey
        end
      end
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
        expect(response).to have_http_status(:bad_request)
      end

      it 'contains read-only data' do
        busted_params = { id: transcription.id, "data": { "type": "transcriptions", "attributes": { "group_id": "fake_id" } } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'roles' do
      before { allow(controller).to receive(:current_user).and_return user }

      context 'without any roles' do
        let(:user) { create(:user, roles: {} )}
        it "returns a 403 Forbidden" do
          patch :update, params: update_params
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'as an admin' do
        let(:user) { create(:user, :admin) }
        it 'updates the resource' do
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end

        it 'allows approval' do
          update_params[:data][:attributes][:status] = "approved"
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end
      end

      context 'as an approver' do
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['owner']}) }
        it 'updates the resource' do
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end

        it 'allows approval' do
          update_params[:data][:attributes][:status] = "approved"
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end
      end

      context 'as an editor' do
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['scientist']}) }
        it 'updates the resource' do
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end

        it 'forbids approval' do
          update_params[:data][:attributes][:status] = "approved"
          patch :update, params: update_params
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['tester']}) }
        it 'returns a 403 Forbidden' do
          patch :update, params: update_params
          expect(response).to have_http_status(:forbidden)
        end

        it 'forbids approval' do
          update_params[:data][:attributes][:status] = "approved"
          patch :update, params: update_params
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe '#export' do
    let(:transcription) { create(:transcription, group_id: 'FROG_LADS_777' ) }
    let(:second_transcription) { create(:transcription, group_id: 'FROG_LADS_777' ) }
    let(:export_single_params) { { id: transcription.id } }
    let(:export_group_params) { { group_id: transcription.group_id } }

    before do
      transcription.files.attach(blank_file_blob)
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
        get :export_group, params: export_group_params
        expect(response).to have_http_status(:ok)
      end

      it 'should have a response with content-type of application/zip' do
        get :export_group, params: export_group_params
        expect(response.header["Content-Type"]).to eq("application/zip")
      end
    end

    describe 'roles' do
      context 'as a viewer' do
        let(:viewer) { create(:user, roles: { transcription.workflow.project.id => ['tester']}) }
        before { allow(controller).to receive(:current_user).and_return viewer }

        it 'returns a 403 Forbidden when exporting one transcription' do
          get :export, params: export_single_params
          expect(response).to have_http_status(:forbidden)
        end

        it 'returns a 500 error when exporting a group' do
          get :export_group, params: export_group_params
          expect(response).to have_http_status(:error)
        end
      end

      context 'as an editor' do
        let(:editor) { create(:user, roles: { transcription.workflow.project.id => ['moderator']}) }
        before { allow(controller).to receive(:current_user).and_return editor }

        it 'returns successfully for a single transcription export' do
          get :export, params: export_single_params
          expect(response).to have_http_status(:ok)
        end

        it 'returns successfully for a group export' do
          get :export_group, params: export_group_params
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
