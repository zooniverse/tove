ActiveRecord::Base.transaction do
  @projects = []
  (1..3).each do |x|
    curr_project = Project.create(slug: "user#{x}/project_#{x}")
    @projects << curr_project if curr_project.valid?

    User.create(login: "user#{x}")
  end

  @workflows = []
  @projects.each do |p|
    (1..3).each do |x|
      @workflows << Workflow.create(project: p, display_name: "Workflow #{x}")
    end
  end

  @workflows.each do |w|
    (1..90).each do |_x|
      Transcription.create(
        workflow: w,
        group_id: 'GROUP' + rand(3).to_s,
        status: rand(3),
        flagged: [true, false].sample,
        text: { abunch: 'oftext' },
        metadata: { checkout: 'thismetadata' }
      )
    end
  end
end
