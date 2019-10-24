RSpec.describe ApplicationController, type: :controller do

  describe '#auth_token' do
    let(:token){ nil }

    before(:each) do
      allow(controller.request).to receive(:headers).and_return('Authorization' => token) if token
    end

    context 'has an authorization header' do
      let(:token) { 'Bearer test' }
      it 'is nil' do
        expect(controller.auth_token).to eql('test')
      end
    end

    context 'without an authorization header' do
      it 'is nil' do
        expect(controller.auth_token).to be_nil
      end
    end
  end

  describe '#set_roles' do
    let(:user){ create :user }
    let(:client_double){ double roles: { 'foo' => ['bar'] } }

    context 'with a user' do
      before(:each) do
        allow(controller).to receive(:current_user).and_return user
      end

      it 'should fetch roles' do
        expect(PanoptesClient).to receive(:new).and_return client_double
        expect(client_double).to receive :roles
        controller.set_roles
      end

      it 'should set the current user roles' do
        allow(PanoptesClient).to receive(:new).and_return client_double
        controller.set_roles
        expect(controller.current_user.roles).to eql 'foo' => ['bar']
      end
    end

    context 'without a user' do
      it 'should not fetch roles' do
        expect(PanoptesClient).to_not receive(:new)
        controller.set_roles
      end
    end
  end
end
