class CaesarImporter
  attr_reader :id, :reducible, :data, :subject

  def initialize(**params)
    @id = params[:id]
    @reducible = params[:reducible]
    @data = params[:data]
    @subject_info = params[:subject]
  end

  def process
    if workflow
      # workflow exists, project must too
      # Just move on, I guess?
    else
      if project
        # project exists, get workflow
        parsed_wf = pull_workflow(@reducible[:id])
        new_wf = Workflow.create(
          id: parsed_wf[:id],
          display_name: parsed_wf[:display_name]
        )
      else
        # project does not exist, get both
        response = pull_wf_and_project(@reducible[:id])
        new_project = Project.create(
          id: response[:project][:id],
          slug: response[:project][:slug]
        )
        new_wf = Workflow.create(
          id: response[:id],
          display_name: response[:display_name],
          project: new_project
        )
      end
    end

    if transcription
      # How is this possible? Do we overwrite?
    else
      # Do I need to ask panoptes? I've already got the metadata.
      new_transcription_attrs = {
        id: subject_info['id'],
        text: data,
        metadata: subject_info['metadata'],

        # NEEDS DB FIELDS

        # make sure this works
        group_id: subject_info['metadata']['group_id'] || 'default',
        internal_id: subject_info['metadata']['internal_id'] || subject_info['id'],

        low_consensus_lines: data['low_consensus_lines'],
        transcribed_lines: data['transcribed_lines'],
        reducer: data['reducer'],
        parameters: data['parameters']

        # Count the number of `frameX` with a regex or some shit
        # number_pages: data[]

      }
      new_transcription = Transcription.new(new_transcription_attrs)

      # What if they forgot them
    end
  end


  def workflow
    @workflow ||= Workflow.find_by(id: reducible[:id])
  end

  def project
    @project ||= Project.find_by(id: workflow.project_id)
  end

  def transcription
    @transcription ||= Transcription.find_by(id: @subject_info['id'])
  end

  def api
     @api ||= PanoptesApi.new(token: nil, admin: true)
  end

  def pull_wf_and_project
    api.workflow(reducible[:id], include_project: true)
  end

  def pull_workflow
    api.workflow(reducible[:id])
  end
end
