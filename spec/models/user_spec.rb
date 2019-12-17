RSpec.describe Subject, type: :model do
  context 'validation' do
    it 'requires a login' do
      expect(build(:user, login: nil)).to_not be_valid
    end
  end
end
