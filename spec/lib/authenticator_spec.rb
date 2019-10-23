RSpec.describe Authenticator, type: :lib do
  describe '.key' do
    it 'should load the public key' do
      expect(Authenticator.key).to be_a OpenSSL::PKey::RSA
    end

    it 'should memoize the key' do
      expect(Authenticator.key.object_id).to eql Authenticator.key.object_id
    end
  end

  describe '.from_token' do
    let(:token){ 'token' }

    it 'should parse the token' do
      expect(Authenticator).to receive(:decode).with 'token'
      Authenticator.from_token token
    end

    it 'should return the payload data' do
      allow(Authenticator).to receive(:decode).and_return [{ 'data' => 'stuff' }]
      expect(Authenticator.from_token(token)).to eql 'stuff'
    end
  end

  describe '.decode' do
    it 'should use JWT' do
      allow(Authenticator).to receive(:key).and_return 'key'
      expect(JWT).to receive(:decode).with 'token', 'key', true, algorithm: 'RS512'
      Authenticator.decode 'token'
    end

    it 'should handle failures' do
      expect(Authenticator.decode(nil)).to eql [{ }]
    end
  end

  describe '.key_path' do
    subject{ Authenticator.key_path.to_s }

    context 'when in production' do
      before(:each) do
        allow(Rails.env).to receive(:production?).and_return true
      end

      it{ is_expected.to match /panoptes-jwt-production\.pub$/ }
    end

    context 'when not in production' do
      it{ is_expected.to match /panoptes-jwt\.pub$/ }
    end
  end
end
