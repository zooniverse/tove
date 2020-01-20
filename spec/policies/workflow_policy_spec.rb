RSpec.describe WorkflowPolicy, type: :policy do
  let(:user) { create(:user, roles: {}) }

  permissions :index?, :show? do
    let(:project) { create(:project) }
    let(:records) { create(:workflow, project: project)}

    it 'permits viewers' do
      user.roles = {project.id => ['tester'] }
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
    let!(:workflow) { create(:workflow) }
    let!(:another_workflow) { create(:workflow) }

    let(:scope) { Pundit.policy_scope!(user, Workflow) }

    context 'viewer' do
      let(:user) { create(:user, roles: { workflow.project.id => ['tester'] }) }
      it 'allows a limited subset' do
        expect(scope.to_a).to include(workflow)
        expect(scope.to_a).not_to include(another_workflow)
      end
    end

    context 'admin' do
      let(:user) { create(:user, :admin) }
      it 'returns all workflows' do
        expect(scope.to_a).to include(workflow, another_workflow)
      end
    end
  end
end
