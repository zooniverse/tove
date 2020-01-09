ActiveRecord::Base.transaction do
  @projects = []
  (1..3).each do |x|
    curr_project = Project.create(slug: "user#{x}/project_#{x}")
    @projects << curr_project if curr_project.valid?

    User.create(login: "user#{x}")
  end

  @workflows = []
  @projects.each do |p|
    @workflows = []
    (1..3).each do |x|
      @workflows << Workflow.create(project: p, display_name: "Workflow #{x}")
    end
  end

  @workflows.each do |w|
    (1..30).each do |_x|
      s = Subject.create(workflow: w, metadata: { abunch: 'ofjson' })
      Transcription.create(
        workflow: w,
        subject: s,
        group_id: 'GROUP' + rand(3).to_s,
        status: rand(3),
        flagged: [true, false].sample,
        text: { abunch: 'ofjson' }
      )
    end
  end
end
