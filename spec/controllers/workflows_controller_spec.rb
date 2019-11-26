RSpec.describe WorkflowsController, type: :controller do
  include_examples 'authenticates'

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
      allow_any_instance_of(Workflow).to receive(:groups).and_return({"FIRST" => 2, "SECOND" => 1})
      get :index
      expect(json_data.first["attributes"]["groups"]).to eq({"FIRST" => 2, "SECOND" => 1})
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
  end

  describe '#show' do
    let!(:workflow) { create(:workflow) }

    it 'returns successfully' do
      get :show, params: { id: workflow.id }
      expect(response).to have_http_status(:ok)
    end

    it 'renders the requested workflow' do
      get :show, params: { id: workflow.id }
      expect(json_data).to have_id(workflow.id.to_s)
    end
  end
end
