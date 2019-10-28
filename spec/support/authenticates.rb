RSpec.shared_examples 'authenticates' do |klass|
  it 'has no user' do
    get :index
    expect(controller.current_user).to be(nil)
  end

  describe 'with a user' do
    let(:current_user){ create :user }

    before :each do
      allow(Authenticator).to receive(:decode).with('token').and_return [{
        'data' => { 'id' => current_user.id, 'login' => current_user.login }
      }]

      @request.headers['Authorization'] = 'Bearer token'
      get :index
    end

    it 'returns a valid user' do
      expect(controller.current_user).to eql(current_user)
    end
  end
end
