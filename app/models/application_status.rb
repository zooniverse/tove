class ApplicationStatus
  def as_json(options = {})
    {
      commit_id: Rails.application.commit_id
    }
  end
end