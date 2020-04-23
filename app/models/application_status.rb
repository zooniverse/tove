class ApplicationStatus
  def as_json(options = {})
    {
      revision: Rails.application.revision
    }
  end
end