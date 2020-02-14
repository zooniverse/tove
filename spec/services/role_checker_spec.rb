RSpec.describe ProjectRoleChecker, type: :service do
  let(:records){ [] }
  let(:user) { create(:user, roles: {'123': ['tester'], '456': ['expert']}) }
  let(:checker){ described_class.new user, records }
  let(:resource_double) { double(id: '123')}
  let(:another_resource_double) { double(id: '456')}
  let(:one_more) { double(id: '666')}

  describe '#viewer_project_ids' do
    it 'returns an array of resource ids' do
      expect(checker.viewer_project_ids).to eq ['123', '456']
    end
  end

  context 'the user has permission' do
    before do
      allow_any_instance_of(described_class).to receive(:check_roles).and_return true
    end

    describe '#can_edit?' do
      it 'returns true when the user has permission' do
        expect(checker.can_edit?).to be true
      end
    end

    describe '#can_approve?' do
      it 'returns true when the user has permission' do
        expect(checker.can_approve?).to be true
      end
    end

    describe '#can_view?' do
      it 'returns true when the user has permission' do
        expect(checker.can_view?).to be true
      end
    end
  end

  context 'the user does not have permission' do
    before do
      allow_any_instance_of(described_class).to receive(:check_roles).and_return false
    end

    describe '#can_edit?' do
      it 'returns false when the user does not have permission' do
        expect(checker.can_edit?).to be false
      end
    end

    describe '#can_approve?' do
      it 'returns false when the user does not have permission' do
        expect(checker.can_approve?).to be false
      end
    end

    describe '#can_view?' do
      it 'returns false when the user does not have permission' do
        expect(checker.can_view?).to be false
      end
    end
  end
end
