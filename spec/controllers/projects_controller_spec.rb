RSpec.describe ProjectsController, type: :controller do

  let(:admin_user) { create :user, :admin }
  before { allow(controller).to receive(:current_user).and_return admin_user }

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
        let(:user) { create(:user, roles: {project.id => ['tester']}) }
        it 'returns the authorized project' do
          get :index
          expect(response).to have_http_status(:ok)
          expect(json_data.size).to eq(1)
          expect(json_data.first["id"]).to eql(project.id.to_s)
        end
      end
    end
  end

  describe '#show' do
    let!(:project) { create(:project, slug: "userone/projectone") }

    describe 'roles' do
      before do
        allow(controller).to receive(:current_user).and_return user
        get :show, params: { id: project.id }
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
          expect(json_data).to have_id(project.id.to_s)
        end
      end

      context 'as a viewer' do
        let(:user) { create(:user, roles: {project.id => ['tester']}) }
        it 'returns the authorized project' do
          expect(response).to have_http_status(:ok)
          expect(json_data["id"]).to eql(project.id.to_s)
        end
      end
    end
  end

  describe '#export' do
    let (:project) { create(:project, slug: "lizard_king/underground_fortress") }
    let (:workflow) { create(:workflow, project: project)}
    let(:transcription) { create(:transcription, :unedited_json_blob, workflow: workflow) }
    let(:export_params) { { id: project.id } }

    before do
      transcription.export_files.attach(blank_file_blob)
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
        let(:viewer) { create(:user, roles: { project.id => ['tester']}) }
        before { allow(controller).to receive(:current_user).and_return viewer }

        it 'returns a 403 Forbidden when exporting a project' do
          get :export, params: export_params
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'as an editor' do
        let(:editor) { create(:user, roles: { project.id => ['moderator']}) }
        before { allow(controller).to receive(:current_user).and_return editor }

        it 'returns successfully when exporting a project' do
          get :export, params: export_params
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
