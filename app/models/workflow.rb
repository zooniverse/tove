class Workflow < ApplicationRecord
  belongs_to :project
  has_many :subjects
  has_many :transcriptions

  validates :display_name, presence: true

  # return an array listing groups that belong to the workflow
  # data contains following information per group:
  #   * group id
  #   * transcription count
  #   * last updated at
  #   * last updated by
  def groups
    transcription_counts = transcriptions.group(:group_id).count(:id)
    # get most recent updated_at date for each group, use .where to join onto transcription table
    groups_last_updated_at = transcriptions.group(:group_id)
                                           .maximum(:updated_at)
                                           .map { |_group, date| date } # get only the date
    groups_data = transcriptions.where(updated_at: groups_last_updated_at)
                                .map do |g|
                                  [g['group_id'],
                                  {
                                    updated_at: g['updated_at'],
                                    updated_by: g['updated_by']
                                  }]
                                end.to_h
    
    # add group count to groups_data object
    groups_data.each do |key, value|
      value[:transcription_count] = transcription_counts[key]
    end
  end

  def total_transcriptions
    transcriptions.count
  end
end
