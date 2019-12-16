class Workflow < ApplicationRecord
  belongs_to :project
  has_many :subjects
  has_many :transcriptions

  validates :display_name, presence: true

  def all_trans
    @all_trans ||= transcriptions.select(:id, :group_id, :status)
  end

  def groups
    transcriptions_per_group = transcriptions.group(:group_id).count(:id)
    group_count = transcriptions_per_group.count

    {
      transcriptions_per_group: transcriptions_per_group,
      group_count: group_count
    }
  end

  def total_transcriptions
    all_trans.count(:all)
  end

  def approved_transcriptions
    all_trans.count { |t| t.status == 'approved' }
  end
end
