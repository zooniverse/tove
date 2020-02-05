RSpec.describe ProjectsController, type: :controller do

  describe '#index' do
    let!(:project) { create(:project, slug: "userone/projectone") }
    let!(:another_project) { create(:project, slug: "usertwo/projecttwo") }

    it_has_behavior "pagination" do
      let(:another) { another_project }
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'should render' do
      get :index
      expect(json_data.first).to have_type('project')
      expect(json_data.first).to have_attribute(:slug)
      expect(json_data.first["id"]).to eql(project.id.to_s)
    end

    describe "filtration" do
      it 'filters by slug' do
        get :index, params: { filter: { slug_cont_any: "two" } }
        expect(response).to have_http_status(:ok)
        expect(json_data.size).to eq(1)
        expect(json_data.first).to have_id(another_project.id.to_s)
      end
    end
  end

  describe '#show' do
    let!(:project) { create(:project, slug: "userone/projectone") }

    it 'returns successfully' do
      get :show, params: { id: project.id }
      expect(response).to have_http_status(:ok)
    end

    it 'renders the requested project' do
      get :show, params: { id: project.id }
      expect(json_data).to have_id(project.id.to_s)
    end
  end

  describe '#export' do
    let (:project) { create(:project, slug: "lizard_king/underground_fortress") }
    let (:workflow) { create(:workflow, project: project)}
    let(:transcription) { create(:transcription, workflow: workflow) }
    let(:export_params) { { id: project.id } }

    before do
      transcription.files.attach(create_file_blob)
    end

    it 'returns successfully' do
      get :export, params: export_params
      expect(response).to have_http_status(:ok)
    end

    it 'should have a response with content-type of application/zip' do
      get :export, params: export_params
      expect(response.header["Content-Type"]).to eq("application/zip")
    end
  end
end
