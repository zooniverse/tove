def json_response
  JSON.parse(response.body).with_indifferent_access
end

def json_data
  JSON.parse(response.body)["data"]
end
