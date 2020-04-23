class ApplicationStatus
  def as_json(options = {})
    {
      revision: Rails.application.commit_id
    }
  end
end