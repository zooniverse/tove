RSpec.describe Workflow, type: :model do
  context 'validating' do
    it 'requires a display name' do
      expect(build(:workflow, display_name: nil)).to_not be_valid
    end
  end

  let!(:workflow) { create(:workflow) }
  let!(:transcription_one) do
    create(:transcription,
           workflow: workflow,
           group_id: 'FIRST',
           status: 2,
           updated_at: '2019-12-16 00:00:00 UTC',
           updated_by: 'Ursula')
  end
  let!(:transcription_two) do
    create(:transcription,
           workflow: workflow,
           group_id: 'FIRST',
           status: 2,
           updated_at: '2019-1-10 00:00:00 UTC',
           updated_by: 'Astrailis')
  end
  let!(:transcription_three) do
    create(:transcription,
           workflow: workflow,
           group_id: 'SECOND',
           status: 0,
           updated_by: 'Dove')
  end

  describe '#transcription_group_data' do
    it 'counts transcriptions per group' do
      expect(workflow.transcription_group_data['FIRST'][:transcription_count]).to eq(2)
    end
    it 'gets the date of the most recently updated transcription' do
      expect(workflow.transcription_group_data['FIRST'][:updated_at]).to eq('2019-12-16 00:00:00 UTC')
    end
    it 'gets the user who last updated a transcription of the group' do
      expect(workflow.transcription_group_data['FIRST'][:updated_by]).to eq('Ursula')
    end
  end

  describe '#total_transcriptions' do
    it 'counts total transcriptions in workflow' do
      expect(workflow.total_transcriptions).to eq(3)
    end
  end
end
