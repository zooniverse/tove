RSpec.describe Subject, type: :model do
  context 'validation' do
    it 'requires a login' do
      expect(build(:user, login: nil)).to_not be_valid
    end
  end

  describe '#from_jwt' do
    it 'creates a valid user with the correct attributes' do
      data = { 'id' => 9999, 'login' => "username" }
      expect {
        User.from_jwt(data)
      }.to change {User.count}.by(1)
      expect(User.find(9999)).to be_valid
    end

    it 'has an invalid JWT' do
      data = { }
      expect {
        User.from_jwt(data)
      }.to raise_error ArgumentError
    end
  end
end
