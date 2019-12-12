ActiveRecord::Base.transaction do
  @projects = []
  (1..3).each do |x|
    @projects << Project.find_or_create_by(slug: "user#{x}/project_#{x}")
    User.find_or_create_by(login: "user#{x}")
  end

  @projects.each do |p|
    @workflows = []
    (1..3).each do |x|
      @workflows << Workflow.find_or_create_by(project: p, display_name: "Workflow #{x}")
    end
  end

  @workflows.each do |w|
    (1..30).each do |x|
      s = Subject.find_or_create_by(workflow: w, metadata: { abunch: "ofjson" })
      Transcription.find_or_create_by(
        workflow: w,
        subject: s,
        group_id: "GROUP" + rand(3).to_s,
        status: rand(3),
        flagged: [true, false].sample,
        text: { abunch: "ofjson" })
    end
  end
end
