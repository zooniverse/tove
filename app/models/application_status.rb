class ApplicationStatus
  def id
    1
  end

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
      id: 1,
      commit_id: commit_id
    }
  end
end
