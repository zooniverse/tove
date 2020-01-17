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

  context 'with a logged in user' do
    before { allow_any_instance_of(ApplicationPolicy).to receive(:logged_in?).and_return true }

    describe '#editor_project_ids' do


      context 'without roles' do
        it 'returns an empty array' do
          expect(policy.editor_project_ids).to eql []
        end
      end

      context 'with non-editor roles' do
        it 'returns an empty array' do
          user.update_attribute(:roles, { 1 => ['foo'] } )
          expect(policy.editor_project_ids).to eql []
        end
      end

      context 'with a set of project roles that include editor roles' do
        it 'returns an array of ids' do
          user.update_attribute(:roles, {
              '1' => ['scientist'],
              '2' => ['owner'],
              '3' => ['tester'],
              '4' => ['collaborator'],
              '5' => ['notarole'],
              '6' => ['owner', 'collaborator']
            }
          )
          expect(policy.editor_project_ids).to eql ['1', '2', '4', '6']
        end
      end
    end
  end
end
