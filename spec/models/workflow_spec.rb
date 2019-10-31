RSpec.describe Workflow, type: :model do
  context 'validating' do
    it 'requires a display name' do
      expect(build(:workflow, display_name: nil)).to_not be_valid
    end
  end

  describe '#groups' do
    let!(:workflow) { create(:workflow) }
    let!(:transcription_one) { create(:transcription, workflow: workflow, group_id: "FIRST") }
    let!(:transcription_two) { create(:transcription, workflow: workflow, group_id: "FIRST") }
    let!(:transcription_three) { create(:transcription, workflow: workflow, group_id: "SECOND") }

    it 'counts groups' do
      expect(workflow.groups).to eq({"FIRST" => 2, "SECOND" => 1})
    end
  end
end
