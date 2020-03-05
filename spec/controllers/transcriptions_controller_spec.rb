RSpec.describe TranscriptionsController, type: :controller do
  let(:admin_user) { create :user, :admin }
  before { allow(controller).to receive(:current_user).and_return admin_user }

  describe '#index' do
    let!(:transcription) { create(:transcription, status: 1, internal_id: 11) }
    let!(:another_transcription) { create(:transcription, workflow: transcription.workflow, status: 0) }
    let!(:separate_transcription) { create(:transcription, group_id: "HONK1", flagged: true, status: 2) }

    it_has_behavior 'pagination' do
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

      it 'filters by internal id' do
        get :index, params: { filter: { internal_id_eq: 11 } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(transcription.id.to_s)
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
        it 'returns a 403' do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'as an admin' do
        let(:user) { create(:user, :admin) }
        it 'returns the full scope' do
          expect(response).to have_http_status(:ok)
          expect(json_data).to have_id(transcription.id.to_s)
        end

        it 'locks the transcription' do
          expect(json_data['attributes']['locked_by']).to eq(user.login)
        end
      end

      context 'as an editor' do
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['expert'] }) }

        it 'locks the transcription' do
          expect(json_data['attributes']['locked_by']).to eq(user.login)
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: {transcription.workflow.project.id => ['tester']}) }
        it 'returns the authorized workflow' do
          expect(response).to have_http_status(:ok)
          expect(json_data['id']).to eql(transcription.id.to_s)
        end
      end
    end
  end

  describe '#update' do
    let!(:transcription) { create(:transcription) }
    let(:update_params) { { id: transcription.id, "data": { "type": "transcriptions", "attributes": { "flagged": 1 } } } }

    before(:each) do
      request.headers['If-Unmodified-Since'] = transcription.updated_at.iso8601(3)
    end

    it 'updates the resource' do
      patch :update, params: update_params
      expect(transcription.reload.flagged).to be_truthy
    end

    it 'saves updated_by user login to record' do
      patch :update, params: update_params
      expect(Transcription.find(transcription.id).updated_by).to eq(admin_user.login)
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

    context 'when last modified date does not match' do
      it 'throws an error' do
        request.headers['If-Unmodified-Since'] = (transcription.updated_at - 1.hours).iso8601(3)
        patch :update, params: update_params
        expect(response).to have_http_status(:error)
      end
    end

    context 'when transcription is locked' do
      context 'when updating user is different from locked by user' do
        let(:transcription) { create(:transcription, locked_by: 'kar-aniyuki', lock_timeout: (DateTime.now + 1.hours)) }

        it 'prevents update' do
          patch :update, params: update_params
          expect(response).to have_http_status(:error)
        end
      end

      context 'when updating user and locked by user are the same' do
        let(:transcription) { create(:transcription, locked_by: admin_user.login, lock_timeout: (DateTime.now + 1.hours)) }

        it 'allows update when updating user and locked by user are the same' do
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe '#unlock' do
    context 'when unlocking user is same as locked by user' do
      let(:transcription) { create(:transcription, locked_by: admin_user.login, lock_timeout: (DateTime.now + 1.hours)) }
      let(:unlock_params) { { id: transcription.id } }

      it 'removes the lock' do
        patch :unlock, params: unlock_params
        expect(Transcription.find(transcription.id).locked_by).to be_nil
      end
    end
  end
end
