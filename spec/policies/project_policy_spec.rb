RSpec.describe ProjectPolicy, type: :policy do
  let(:user) { create(:user, roles: {}) }

  permissions :index?, :show? do
    let!(:records) { create :project }
    it 'permits viewers' do
      user.roles = {records.id => ['tester'] }
      expect(described_class).to permit(user, records)
    end

    it 'permits admins' do
      user.admin = true
      expect(described_class).to permit(user, records)
    end

    it 'forbids unauthorized users' do
      expect(described_class).not_to permit(user, records)
    end

    it 'forbids unauthorized requests' do
      user = nil
      expect{described_class.new(user, records)}.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "Scope" do
    let!(:projects) {create_list(:project, 2)}
    let(:scope) { Pundit.policy_scope!(user, Project) }

    context 'viewer' do
      let(:user) { create(:user, roles: { projects[0].id => ['tester'] }) }
      it 'allows a limited subset' do
        expect(scope.to_a).to include(projects[0])
        expect(scope.to_a).not_to include(projects[1])
      end
    end

    context 'admin' do
      let(:user) { create(:user, :admin) }
      it 'returns all projects' do
        expect(scope.to_a).to include(projects[0], projects[1])
      end
    end
  end
end
