RSpec.describe ApplicationPolicy, type: :policy do
  let(:records){ [] }
  let(:user) { create(:user, roles: {}) }
  let(:policy){ ApplicationPolicy.new user, records }

  context 'with a user' do
    it 'acts logged in' do
      expect(policy.logged_in?).to be true
      expect(policy.admin?).to be false
    end

    it 'acts like an admin' do
      user.admin = true
      new_policy = ApplicationPolicy.new user, records
      expect(policy.logged_in?).to be true
      expect(policy.admin?).to be true
    end
  end

  context 'without a user' do
    it 'is not logged in' do
      expect{ApplicationPolicy.new(nil, records)}.to raise_error Pundit::NotAuthorizedError
    end
  end
end
