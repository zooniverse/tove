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
  def transcription_group_data
    transcription_group_data = {}
    group_transcriptions = ordered_transcription_groups.group_by { |group| group.group_id }
    group_transcriptions.each do |group_id, data|
      # take the first/latest update_at transcription
      transcription = data.first
      # get the count from the number of transcriptions in the group
      # Note: this may be sub-optimal if a group can have a large number transcriptions
      # as we only use the data in the first record and count the rest only.
      group_transcription_count = data.count

      # construct the resulting data record results
      #
      # IMHO these look a lot like a data record that could easily be stored in the database
      # and we're getting into another association territory with this method
      # especially as the workflow is really leaning on the transcription assocation here,
      # it's not really anything to do with a workflow but it's serialized as a workflow attribute...
      transcription_group_data[group_id] =
        {
          updated_at: transcription.max_date,
          updated_by: transcription.updated_by,
          transcription_count: group_transcription_count
        }
    end

    transcription_group_data
  end

  def total_transcriptions
    transcriptions.count
  end

  private

  # fetch the grouped workflow transcriptions
  # along with the groups latest transcription updated_at
  # we also sort the group transcriptions so the first record is the latest transcription
  def ordered_transcription_groups
    transcriptions
      .select( "group_id, updated_by, max(updated_at) as max_date")
      .group(:group_id, :updated_by)
      .order("max_date DESC, group_id")
  end
end
