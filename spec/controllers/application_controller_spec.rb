RSpec.describe ApplicationController, type: :controller do
  let(:user){ create :user }

  describe 'error handling' do
    controller do
      def index
        raise StandardError
      end
    end

    it 'sends StandardErrors to Sentry' do
      allow(controller).to receive(:current_user).and_return user
      expect(controller).to receive(:report_to_sentry).and_call_original
      expect(Raven).to receive(:capture_exception)
      get :index
      expect(response).to have_http_status(500)
    end
  end

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
      allow(api_double).to receive(:authenticated_user_id).and_return('1234567')
      allow(api_double).to receive(:authenticated_user_login).and_return('myusername')
      allow(api_double).to receive(:authenticated_user_display_name).and_return('My Username')
      allow(api_double).to receive(:authenticated_admin?).and_return(true)

      allow(api_double).to receive(:roles).and_return({ 'foo' => ['bar'] })

      allow(controller).to receive(:panoptes).and_return(api_double)
      allow(controller).to receive(:auth_token).and_return(true)
    end

    describe 'user attribute checking' do
      let(:user){ create :user, roles: {}, admin: false, display_name: "default" }

      before do
        allow(controller).to receive(:current_user).and_return user
      end

      describe '#needs_roles_refresh?' do
        before do
          allow(api_double).to receive(:token_created_at).and_return(Time.now - 1.hour)
        end

        it 'is true when the roles are nil' do
          user.roles = nil
          expect(controller.needs_roles_refresh?).to be true
        end

        it 'is true when the roles are old' do
          user.roles_refreshed_at = Time.now - 2.days
          expect(controller.needs_roles_refresh?).to be true
        end

        it 'is false when the roles are fresh' do
          user.roles_refreshed_at = Time.now - 2.seconds
          expect(controller.needs_roles_refresh?).to be false
        end
      end

      describe '#admin_status_changed?' do
        it 'is true when the flag is different' do
          allow(api_double).to receive(:authenticated_admin?).and_return(true)
          expect(controller.admin_status_changed?).to be true
        end

        it 'is false when the flag is the same' do
          allow(api_double).to receive(:authenticated_admin?).and_return(false)
          expect(controller.admin_status_changed?).to be false
        end
      end

      describe '#display_name_changed?' do
        it 'is true when the flag is different' do
          allow(api_double).to receive(:authenticated_user_display_name).and_return("changed")
          expect(controller.display_name_changed?).to be true
        end

        it 'is false when the name is the same' do
          allow(api_double).to receive(:authenticated_user_display_name).and_return("default")
          expect(controller.display_name_changed?).to be false
        end
      end
    end

    describe '#set_user' do
      before do
        allow(controller).to receive(:needs_roles_refresh?).and_return(true)
      end

      context 'with a valid JWT' do
        it 'creates a user' do
          expect{controller.set_user}.to change{User.count}.by(1)
          expect(User.find(1234567)).to be_valid
        end

        it 'sets user roles when they need to be refreshed' do
          expect(controller).to receive(:set_roles)
          controller.set_user
        end

        it 'does not set roles when they are fresh' do
          allow(controller).to receive(:needs_roles_refresh?).and_return(false)
          expect(controller).to_not receive(:set_roles)
          controller.set_user
        end
      end

      context 'with an expired JWT' do
        controller do
          def index
            raise Panoptes::Client::AuthenticationExpired
          end
        end

        it 'raises an error' do
          allow(api_double).to receive(:authenticated_user_id).and_raise(Panoptes::Client::AuthenticationExpired)
          expect{controller.set_user}.to raise_error Panoptes::Client::AuthenticationExpired
        end

        it 'serializes the error' do
          get :index
          expect(response).to have_http_status(401)
        end
      end
    end

    describe '#set_roles' do
      let(:user){ create :user, roles: {}, roles_refreshed_at: (Time.now - 2.days)}

      context 'with a user' do
        before(:each) do
          allow(controller).to receive(:current_user).and_return user
        end

        it 'fetches project roles' do
          expect(api_double).to receive :roles
          controller.set_roles
        end

        it "sets the current user's project roles" do
          controller.set_roles
          expect(user.roles).to eql 'foo' => ['bar']
        end

        it 'updates the refreshed at timestamp' do
          controller.set_roles
          expect{controller.set_roles}.to change { user.roles_refreshed_at }
        end
      end

      context 'without a user' do
        it 'does not fetch roles' do
          expect(PanoptesApi).to_not receive(:new)
          controller.set_roles
        end
      end
    end
  end
end
