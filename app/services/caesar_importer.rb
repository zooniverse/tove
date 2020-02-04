class CaesarImporter
  attr_reader :reduction_id, :reducible, :data, :subject_info

  def initialize(id:, reducible:, data:, subject:)
    @reduction_id = id
    @reducible = reducible
    @data = data
    @subject_info = subject
  end

  def process
    generate_parent_resources

    # If a transcription with this id already exists, an exception will be raised
    new_transcription = Transcription.new(transcription_create_attrs)
    new_transcription.workflow = workflow
    new_transcription.save!
  end

  private

  def workflow
    Workflow.find_by(id: reducible[:id])
  end

  def generate_parent_resources
    # If the workflow exists, the project does too
    unless workflow
      response = pull_wf_and_project
      existing_project = Project.find_by(id: response[:project][:id])

      if existing_project
        # Project exists, create workflow
        new_wf = Workflow.create!(
          id: response[:id],
          display_name: response[:display_name],
          project: existing_project
        )
      else
        # project does not exist, create both
        new_project = Project.create!(
          id: response[:project][:id],
          slug: response[:project][:slug]
        )
        new_wf = Workflow.create!(
          id: response[:id],
          display_name: response[:display_name],
          project: new_project
        )
      end
    end
  end

  def transcription_create_attrs
    {
      id: subject_info[:id],
      status: 0,
      text: data,
      metadata: subject_info[:metadata],
      group_id: subject_info[:metadata][:group_id] || 'default',
      internal_id: subject_info[:metadata][:internal_id] || subject_info[:id],
      low_consensus_lines: data[:low_consensus_lines],
      total_lines: data[:transcribed_lines],
      reducer: data[:reducer],
      parameters: data[:parameters],
      total_pages: data.keys.grep(/frame/).count
    }
  end

  def api
     @api ||= ClientPanoptesApi.new
  end

  def pull_wf_and_project
    api.workflow(reducible[:id], include_project: true)
  end
end
