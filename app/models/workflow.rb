class Workflow < ApplicationRecord
  belongs_to :project
  has_many :subjects
  has_many :transcriptions

  validates :display_name, presence: true

  def groups
    transcriptions_per_group = transcriptions.group(:group_id).count
    # total_count = transcriptions_per_group.values.reduce(:+)
    group_count = transcriptions_per_group.count

    {
      transcriptions_per_group: transcriptions_per_group,
      # total_transcriptions: total_count,
      group_count: group_count
    }
  end

  def total_transcriptions
    transcriptions.count
  end

  def approved_transcriptions
    transcriptions.count { |t| t.status == 'approved' }
  end
end
