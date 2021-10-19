RSpec.describe TranscriptionsController, type: :controller do
  let(:admin_user) { create :user, :admin }
  before { allow(controller).to receive(:current_user).and_return admin_user }

  describe '#index' do
    let!(:transcription) { create(:transcription, status: 1, internal_id: 11) }
    let!(:another_transcription) { create(:transcription, workflow: transcription.workflow, status: 0, updated_at: '2020-20-20 20:00:00', updated_by: 'kar-aniyuki') }
    let!(:separate_transcription) { create(:transcription, group_id: 'HONK1', flagged: true, status: 2, low_consensus_lines: 3, total_pages: 2, total_lines: 6) }

    it_has_behavior 'pagination' do
      let(:another) { another_transcription }
    end

    describe 'roles' do
      before { allow(controller).to receive(:current_user).and_return user }

      context 'without any roles' do
        let(:user) { create(:user, roles: {}) }
        it 'returns return an empty response' do
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
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['tester'] }) }
        it 'returns the authorized workflow' do
          get :index
          expect(response).to have_http_status(:ok)
          expect(json_data.first).to have_type('transcription')
          expect(json_data.first).to have_jsonapi_attributes(:status, :flagged)
          expect(json_data.first['id']).to eql(transcription.id.to_s)
          expect(json_data.size).to eq(2)
        end

        it 'displays the correct approved_count meta' do
          get :index
          expect(response).to have_http_status(:ok)
          response_meta = JSON.parse(response.body)['meta']
          expect(response_meta['approved_count_fraction']).not_to be_nil
          expected_fraction = "#{Transcription.where(status: 0).count}/#{response_meta['pagination']['records']}"
          expect(response_meta['approved_count_fraction']).to eq(expected_fraction)
        end
      end
    end

    describe 'filtration' do
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
          expect(json_data.first['attributes']['status']).to eq(another_transcription.status)
        end

        it 'filters by multiple status ids' do
          status_filter = "#{another_transcription.status_before_type_cast},#{separate_transcription.status_before_type_cast}"
          get :index, params: { filter: { status_in: status_filter } }
          expect(json_data.size).to eq(2)
        end

        it 'filters by status term' do
          get :index, params: { filter: { status_eq: another_transcription.status } }
          expect(json_data.size).to eq(1)
          expect(json_data.first['attributes']['status']).to eq(another_transcription.status)
        end

        it 'filters by multiple status terms' do
          status_filter = "#{another_transcription.status},#{separate_transcription.status}"
          get :index, params: { filter: { status_in: status_filter } }
          expect(json_data.size).to eq(2)
        end
      end

      it 'filters by updated by' do
        get :index, params: { filter: { updated_by_eq: another_transcription.updated_by } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(another_transcription.id.to_s)
      end

      it 'filters by updated at' do
        transcription.update_column(:updated_at, Time.now + 1.hour)
        get :index, params: { filter: { updated_at_gteq: transcription.updated_at } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(transcription.id.to_s)
      end

      it 'filters by low consensus lines' do
        get :index, params: { filter: { low_consensus_lines_eq: separate_transcription.low_consensus_lines } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(separate_transcription.id.to_s)
      end

      it 'filters by total pages' do
        get :index, params: { filter: { total_pages_eq: separate_transcription.total_pages } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(separate_transcription.id.to_s)
      end

      it 'filters by total lines' do
        get :index, params: { filter: { total_lines_eq: separate_transcription.total_lines } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(separate_transcription.id.to_s)
      end
    end
  end

  describe '#show' do
    let!(:transcription) { create(:transcription, status: 'unseen') }
    let(:user) { create(:user, :admin) }

    before do
      allow(controller).to receive(:current_user).and_return user
    end

    it 'serializes the updated_at date in the "Last-Modified" header' do
      get :show, params: { id: transcription.id }
      expect(response.header['Last-Modified']).to eq(transcription.updated_at.httpdate)
    end

    it 'updates status to \'in progress\' if status is \'unseen\'' do
      get :show, params: { id: transcription.id }
      expect(json_data['attributes']['status']).to eq('in_progress')
    end

    it 'does not change status when status is not \'unseen\'' do
      approved_transcription = create(:transcription, status: 'approved')
      get :show, params: { id: approved_transcription.id }
      expect(json_data['attributes']['status']).to eq('approved')
    end

    describe 'roles' do
      let(:locked_transcription) { create(:transcription, locked_by: 'kar-aniyuki', lock_timeout: (DateTime.now + 1.hours)) }

      context 'without any roles' do
        let(:user) { create(:user, roles: {}) }

        it 'returns a 403' do
          get :show, params: { id: transcription.id }
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'as an admin' do
        let(:user) { create(:user, :admin) }

        it 'returns the full scope' do
          get :show, params: { id: transcription.id }
          expect(response).to have_http_status(:ok)
          expect(json_data).to have_id(transcription.id.to_s)
        end

        it 'locks the transcription if not already locked' do
          get :show, params: { id: transcription.id }
          expect(json_data['attributes']['locked_by']).to eq(user.login)
        end

        it 'does not lock the transcription if it is already locked' do
          expect do
            get :show, params: { id: transcription.id }
          end.not_to(change { locked_transcription.locked_by })
        end
      end

      context 'as an editor' do
        let(:editor_roles) do
          {
            transcription.workflow.project.id => ['expert'],
            locked_transcription.workflow.project.id => ['expert']
          }
        end
        let(:user) { create(:user, roles: editor_roles) }

        it 'locks the transcription if not already locked' do
          get :show, params: { id: transcription.id }
          expect(json_data['attributes']['locked_by']).to eq(user.login)
        end

        it 'does not lock the transcription if it is already locked' do
          expect do
            get :show, params: { id: transcription.id }
          end.not_to(change { locked_transcription.locked_by })
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['tester'] }) }

        it 'returns the authorized workflow' do
          get :show, params: { id: transcription.id }
          expect(response).to have_http_status(:ok)
          expect(json_data['id']).to eql(transcription.id.to_s)
        end

        it 'does not lock the transcription' do
          get :show, params: { id: transcription.id }
          expect(Transcription.find(transcription.id).locked_by).to be_nil
        end
      end
    end
  end

  describe '#update' do
    let!(:transcription) { create(:transcription) }
    let(:update_params) { { id: transcription.id, "data": { "type": 'transcriptions', "attributes": { "flagged": 1 } } } }

    before(:each) do
      request.headers['If-Unmodified-Since'] = transcription.updated_at.httpdate
    end

    it 'updates the resource' do
      patch :update, params: update_params
      expect(transcription.reload.flagged).to be_truthy
    end

    it 'serializes the updated_at date in the "Last-Modified" header' do
      patch :update, params: update_params
      expect(response.header['Last-Modified']).to eq(transcription.reload.updated_at.httpdate)
    end

    it 'saves updated_by user login to record' do
      patch :update, params: update_params
      expect(Transcription.find(transcription.id).updated_by).to eq(admin_user.login)
    end

    context 'when transcription status changes' do
      context 'when a transcription is approved' do
        it 'attaches 4 data files to the transcription' do
          update_params[:data][:attributes][:status] = 'approved'
          patch :update, params: update_params
          expect(transcription.export_files.count).to eq(4)
        end
      end

      context 'when a transcription is unapproved' do
        it 'removes attached data files from storage' do
          update_params[:data][:attributes][:status] = 'ready'
          patch :update, params: update_params
          expect(transcription.export_files.attached?).to be_falsey
        end
      end
    end

    context 'validates the request' do
      it 'is not valid JSON:API' do
        busted_params = { id: transcription.id, "data": { "nothing": 'garbage' } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not exist' do
        busted_params = { id: 9999, "data": { "type": 'transcriptions', "attributes": { "flagged": true } } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:not_found)
      end

      it 'is the wrong type' do
        busted_params = { id: transcription.id, "data": { "type": 'projects', "attributes": { "flagged": true } } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'contains an invalid attribute' do
        busted_params = { id: transcription.id, "data": { "type": 'transcriptions', "attributes": { "garf": true } } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'contains read-only data' do
        busted_params = { id: transcription.id, "data": { "type": 'transcriptions', "attributes": { "group_id": 'fake_id' } } }
        patch :update, params: busted_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'doesnt have the "If-Unmodified-Since" header set' do
        request.headers['If-Unmodified-Since'] = ''
        patch :update, params: update_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'the "If-Unmodified-Since" header doesnt have a valid date set' do
        request.headers['If-Unmodified-Since'] = 'not a date'
        patch :update, params: update_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'has been updated since the "If-Unmodified-Since" date' do
        request.headers['If-Unmodified-Since'] = (DateTime.now - 1.hour).httpdate
        patch :update, params: update_params
        expect(response).to have_http_status(:conflict)
      end
    end

    describe 'roles' do
      before { allow(controller).to receive(:current_user).and_return user }

      context 'without any roles' do
        let(:user) { create(:user, roles: {}) }
        it 'returns a 403 Forbidden' do
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
          update_params[:data][:attributes][:status] = 'approved'
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end
      end

      context 'as an approver' do
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['owner'] }) }
        it 'updates the resource' do
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end

        it 'allows approval' do
          update_params[:data][:attributes][:status] = 'approved'
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end
      end

      context 'as an editor' do
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['scientist'] }) }
        it 'updates the resource' do
          patch :update, params: update_params
          expect(response).to have_http_status(:ok)
        end

        it 'forbids approval' do
          update_params[:data][:attributes][:status] = 'approved'
          patch :update, params: update_params
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: { transcription.workflow.project.id => ['tester'] }) }
        it 'returns a 403 Forbidden' do
          patch :update, params: update_params
          expect(response).to have_http_status(:forbidden)
        end

        it 'forbids approval' do
          update_params[:data][:attributes][:status] = 'approved'
          patch :update, params: update_params
          expect(response).to have_http_status(:forbidden)
        end
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

        before(:each) do
          patch :update, params: update_params
        end

        it 'allows update' do
          expect(response).to have_http_status(:ok)
        end

        it 'allows subsequent updates' do
          request.headers['If-Unmodified-Since'] = response.header['Last-Modified']
          controller.instance_variable_set(:@update_attrs, nil) # reset instance variable

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

    context 'when unlocking user is different from locked by user' do
      let(:transcription) { create(:transcription, locked_by: 'kar-aniyuki', lock_timeout: (DateTime.now + 1.hours)) }
      let(:unlock_params) { { id: transcription.id } }

      it 'does not remove the lock' do
        patch :unlock, params: unlock_params
        expect(response).to have_http_status(:forbidden)
        expect(Transcription.find(transcription.id).locked_by).to eq(transcription.locked_by)
      end
    end
  end

  context 'exporting transcriptions' do
    let(:transcription) { create(:transcription, group_id: 'FROG_LADS_777') }
    let(:second_transcription) { create(:transcription, group_id: 'FROG_LADS_777') }
    let(:export_single_params) { { id: transcription.id } }
    let(:export_group_params) { { group_id: transcription.group_id, workflow_id: transcription.workflow_id } }

    before do
      transcription.export_files.attach(blank_file_blob)
    end

    describe '#export' do
      it 'returns successfully' do
        get :export, params: export_single_params
        expect(response).to have_http_status(:ok)
      end

      it 'should have a response with content-type of application/zip' do
        get :export, params: export_single_params
        expect(response.header['Content-Type']).to eq('application/zip')
      end

      context 'when transcription has no attached export files' do
        it 'returns a 404 not found' do
          get :export, params: { id: second_transcription.id }
          expect(response).to have_http_status(:not_found)
        end
      end

      it 'should report internal server error to sentry in the case of a UndefinedConversionError' do
        allow(controller).to receive(:export) { raise Encoding::UndefinedConversionError }
        expect(Raven).to receive(:capture_exception)
        get :export, params: export_single_params
      end

      describe 'roles' do
        context 'as a viewer' do
          let(:viewer) { create(:user, roles: { transcription.workflow.project.id => ['tester'] }) }
          before { allow(controller).to receive(:current_user).and_return viewer }

          it 'returns a 403 Forbidden when exporting one transcription' do
            get :export, params: export_single_params
            expect(response).to have_http_status(:forbidden)
          end
        end

        context 'as an editor' do
          let(:editor) { create(:user, roles: { transcription.workflow.project.id => ['moderator'] }) }
          before { allow(controller).to receive(:current_user).and_return editor }

          it 'returns successfully for a single transcription export' do
            get :export, params: export_single_params
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    describe '#export_group' do
      before { allow(DataExports::AggregateMetadataFileGenerator).to receive(:generate_group_file).and_return(true) }
      # TO DO: create example for no trans in group
      context 'when group contains at least one transcription' do
        it 'returns successfully with content-type of application/zip' do
          get :export_group, params: export_group_params
          expect(response).to have_http_status(:ok)
          expect(response.header['Content-Type']).to eq('application/zip')
        end

        describe 'roles' do
          context 'as a viewer' do
            let(:viewer) { create(:user, roles: { transcription.workflow.project.id => ['tester'] }) }
            before { allow(controller).to receive(:current_user).and_return viewer }

            it 'returns a 403 error' do
              get :export_group, params: export_group_params
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'as an editor' do
            it 'returns successfully' do
              get :export_group, params: export_group_params
              expect(response).to have_http_status(:ok)
            end
          end
        end
      end

      context 'when group contains no transcriptions' do
        it 'returns a 404 not found' do
          get :export_group, params: { group_id: 'MICE_IN_TANKS', workflow_id: transcription.workflow_id }
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
