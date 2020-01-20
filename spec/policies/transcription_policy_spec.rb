RSpec.describe TranscriptionPolicy, type: :policy do
  let(:user) { create(:user, roles: {}) }

  permissions :index?, :show? do
    let(:records) { create(:transcription) }

    it 'permits viewers' do
      user.roles = {records.workflow.project.id => ['tester'] }
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

  permissions :update? do
    let(:records) { create(:transcription) }

    it 'permits admins' do
      user.admin = true
      expect(described_class).to permit(user, records)
    end

    it 'permits editors' do
      user.roles = {records.workflow.project.id => ['expert'] }
      expect(described_class).to permit(user, records)
    end

    it 'forbids viewers' do
      user.roles = {records.workflow.project.id => ['tester'] }
      expect(described_class).not_to permit(user, records)
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
    let!(:transcription) { create(:transcription)}
    let!(:another_transcription) { create(:transcription)}
    let(:scope) { Pundit.policy_scope!(user, Transcription) }

    context 'viewer' do
      let(:user) { create(:user, roles: { transcription.workflow.project.id => ['tester'] }) }
      it 'allows a limited subset' do
        expect(scope.to_a).to include(transcription)
        expect(scope.to_a).not_to include(another_transcription)
      end
    end

    context 'admin' do
      let(:user) { create(:user, :admin) }
      it 'returns all workflows' do
        expect(scope.to_a).to include(transcription, another_transcription)
      end
    end
  end
end
