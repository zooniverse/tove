ActiveRecord::Base.transaction do
  if Project.count < 3  # assume we've already seeded if we have 3+ projects
    @projects = []
    (1..3).each do |x|
      @projects << Project.create(slug: "user#{x}/project_#{x}")
      User.create(login: "user#{x}")
    end
  
    @projects.each do |p|
      @workflows = []
      (1..3).each do |x|
        @workflows << Workflow.create(project: p, display_name: "Workflow #{x}")
      end
    end
  
    @workflows.each do |w|
      (1..30).each do |x|
        s = Subject.create(workflow: w, metadata: { abunch: "ofjson" })
        Transcription.create(
          workflow: w,
          subject: s,
          group_id: "GROUP" + rand(3).to_s,
          status: rand(3),
          flagged: [true, false].sample,
          text: { abunch: "ofjson" })
      end
    end
  end
end