RSpec.describe StatusController, type: :controller do
  describe '#show' do
    Rails.application.commit_id = 'example-id-3f8b092f285a'

    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:ok)
    end

    it 'returns the commit id' do
      get :show
      expect(response.body).to eq({:commit_id => 'example-id-3f8b092f285a'}.to_json)
    end
  end
end