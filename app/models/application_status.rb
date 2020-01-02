class ApplicationStatus
  def commit_id
    path = Rails.root.join('commit_id.txt')
    if File.exist? path
      File.read(path)
    else
      'N/A'
    end
  end

  def as_json(options = {})
    {
      commit_id: commit_id
    }
  end
end
