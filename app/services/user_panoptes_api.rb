class UserPanoptesApi < PanoptesApi
  def initialize(token)
    @auth = { token: token }
  end
end
