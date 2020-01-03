class ApplicationStatusSerializer
    include FastJsonapi::ObjectSerializer
  
    attributes :commit_id
  end