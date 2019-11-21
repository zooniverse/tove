RSpec.describe ProjectsController, type: :controller do
  include_examples 'authenticates'

  describe '#index' do
    let!(:project) { create(:project, slug: "userone/projectone") }
    let!(:another_project) { create(:project, slug: "usertwo/projecttwo") }

    it_behaves_like "meta pagination"

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

    describe "pagination" do
      it 'respects page size' do
        get :index, params: { page: { size: 1 } }
        expect(json_data.size).to eql(1)
      end

      it 'respects page number' do
        get :index, params: { page: { number: 2, size: 1 } }
        expect(json_data.first["id"]).to eql(another_project.id.to_s)
      end
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
end
