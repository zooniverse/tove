RSpec.describe ApplicationController, type: :controller do

  describe '#auth_token' do
    let(:token){ nil }

    before(:each) do
      allow(controller.request).to receive(:headers).and_return('Authorization' => token) if token
    end

    context 'has an authorization header' do
      let(:token) { 'Bearer test' }
      it 'exists' do
        expect(controller.auth_token).to eql('test')
      end
    end

    context 'without an authorization header' do
      it 'is nil' do
        expect(controller.auth_token).to be_nil
      end
    end
  end

  describe '#panoptes' do
    it 'instantiates a new Panoptes client instance' do
      expect(PanoptesApi).to receive(:new)
      controller.panoptes
    end
  end

  context 'using the Panoptes client' do
    let(:api_double) { instance_double(PanoptesApi) }
    let(:client) { double }

    before(:each) do
      allow(api_double).to receive(:client).and_return(client)
      allow(client).to receive(:authenticated_user_id).and_return('1234567')
      allow(client).to receive(:authenticated_user_login).and_return('myusername')
      allow(client).to receive(:authenticated_user_display_name).and_return('My Username')
      allow(client).to receive(:authenticated_admin?).and_return(true)

      allow(api_double).to receive(:roles).and_return({ 'foo' => ['bar'] })

      allow(controller).to receive(:panoptes).and_return(api_double)
      allow(controller).to receive(:auth_token).and_return(true)
    end

    describe '#set_user' do
      context 'with a valid JWT' do
        it 'creates a user' do
          expect{controller.set_user}.to change{User.count}.by(1)
          expect(User.find(1234567)).to be_valid
        end
      end

      context 'with an expired JWT' do
        controller do
          def index
            raise Panoptes::Client::AuthenticationExpired
          end
        end

        it 'raises an error' do
          allow(api_double.client).to receive(:authenticated_user_id).and_raise(Panoptes::Client::AuthenticationExpired)
          expect{controller.set_user}.to raise_error Panoptes::Client::AuthenticationExpired
        end

        it 'serializes the error' do
          get :index
          expect(response).to have_http_status(401)
        end
      end
    end

    describe '#set_roles' do
      let(:user){ create :user }

      context 'with a user' do
        before(:each) do
          allow(controller).to receive(:current_user).and_return user
        end

        it 'should fetch roles' do
          expect(api_double).to receive :roles
          controller.set_roles
        end

        it 'should set the current user roles' do
          controller.set_roles
          expect(controller.current_user.roles).to eql 'foo' => ['bar']
        end
      end

      context 'without a user' do
        it 'should not fetch roles' do
          expect(PanoptesApi).to_not receive(:new)
          controller.set_roles
        end
      end
    end
  end
end
