RSpec.describe Workflow, type: :model do
  context 'validating' do
    it 'requires a display name' do
      expect(build(:workflow, display_name: nil)).to_not be_valid
    end
  end

  let!(:workflow) { create(:workflow) }
  let!(:transcription_one) { create(:transcription, workflow: workflow, group_id: 'FIRST', status: 2) }
  let!(:transcription_two) { create(:transcription, workflow: workflow, group_id: 'FIRST', status: 2) }
  let!(:transcription_three) { create(:transcription, workflow: workflow, group_id: 'SECOND', status: 0) }

  describe '#groups' do
    it 'counts transcriptions per group' do
      expect(workflow.groups[:transcriptions_per_group]).to eq('FIRST' => 2, 'SECOND' => 1)
    end

    it 'counts total groups in workflow' do
      expect(workflow.groups[:group_count]).to eq(2)
    end
  end

  describe '#total_transcriptions' do
    it 'counts total transcriptions in workflow' do
      expect(workflow.total_transcriptions).to eq(3)
    end
  end

  describe '#approved_transcriptions' do
    it 'counts approved transcriptions in workflow' do
      expect(workflow.approved_transcriptions).to eq(2)
    end
  end
end
