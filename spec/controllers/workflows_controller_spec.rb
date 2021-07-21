RSpec.describe WorkflowsController, type: :controller do

  let(:admin_user) { create :user, :admin }
  before { allow(controller).to receive(:current_user).and_return admin_user }

  describe '#index' do
    let!(:workflow) { create(:workflow) }
    let!(:another_workflow) { create(:workflow, display_name: "honkhonk") }
    let(:project_two) { another_workflow.project }

    it_has_behavior "pagination" do
      let(:another) { another_workflow }
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'should render' do
      get :index
      expect(json_data.first).to have_type('workflow')
      expect(json_data.first).to have_attribute(:display_name)
      expect(json_data.first["id"]).to eql(workflow.id.to_s)
    end

    it 'serialized transcription groups' do
      allow_any_instance_of(Workflow).to receive(:transcription_group_data)
                                         .and_return({
                                            'FIRST' => {
                                              "updated_at": '2019-12-16 00:00:00 UTC',
                                              "updated_by": 'The Dark Master',
                                              "transcription_count": 1
                                            },
                                            "SECOND" => {
                                              "updated_at": '2019-12-18 00:00:00 UTC',
                                              "updated_by": 'The Grey Tiger',
                                              "transcription_count": 2
                                            }})
      get :index
      expect(json_data.first["attributes"]["groups"]).to eq(
        {"FIRST" => {
          "updated_at" => '2019-12-16 00:00:00 UTC',
          "updated_by" => 'The Dark Master',
          "transcription_count" => 1
        },
        "SECOND" => {
          "updated_at" => '2019-12-18 00:00:00 UTC',
          "updated_by" => 'The Grey Tiger',
          "transcription_count" => 2
        }})
    end

    describe "filtration" do
      it 'filters by display name' do
        get :index, params: { filter: { display_name_cont_any: "honk" } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(another_workflow.id.to_s)
      end

      it 'filters by project id' do
        get :index, params: { filter: { project_id_eq: project_two.id } }
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(another_workflow.id.to_s)
      end
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
          expect(json_data.size).to eq(2)
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: {workflow.project.id => ['tester']}) }
        it 'returns the authorized workflow' do
          get :index
          expect(response).to have_http_status(:ok)
          expect(json_data.size).to eq(1)
          expect(json_data.first["id"]).to eql(workflow.id.to_s)
        end
      end
    end
  end

  describe '#show' do
    let!(:workflow) { create(:workflow) }

    describe 'roles' do
      before do
        allow(controller).to receive(:current_user).and_return user
        get :show, params: { id: workflow.id }
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
          expect(json_data).to have_id(workflow.id.to_s)
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: {workflow.project.id => ['tester']}) }
        it 'returns the authorized workflow' do
          expect(response).to have_http_status(:ok)
          expect(json_data["id"]).to eql(workflow.id.to_s)
        end
      end
    end
  end

  describe '#export' do
    let (:workflow) { create(:workflow)}
    let(:transcription) { create(:transcription, workflow: workflow) }
    let(:export_params) { { id: workflow.id } }

    before do
      transcription.export_files.attach(blank_file_blob)
      allow(DataExports::AggregateMetadataFileGenerator).to receive(:generate_workflow_file).and_return(true)
    end

    it 'returns successfully' do
      get :export, params: export_params
      expect(response).to have_http_status(:ok)
    end

    it 'should have a response with content-type of application/zip' do
      get :export, params: export_params
      expect(response.header["Content-Type"]).to eq("application/zip")
    end

    describe 'roles' do
      context 'as a viewer' do
        let(:viewer) { create(:user, roles: { workflow.project.id => ['tester']}) }
        before { allow(controller).to receive(:current_user).and_return viewer }

        it 'returns a 403 Forbidden when exporting a workflow' do
          get :export, params: export_params
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'as an editor' do
        let(:editor) { create(:user, roles: { workflow.project.id => ['moderator']}) }
        before { allow(controller).to receive(:current_user).and_return editor }

        it 'returns successfully when exporting a workflow' do
          get :export, params: export_params
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
