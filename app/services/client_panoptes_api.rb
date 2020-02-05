class ClientPanoptesApi < PanoptesApi
  def initialize
    @auth = {
              client_id: Rails.application.credentials.panoptes_client_id,
              client_secret: Rails.application.credentials.panoptes_client_secret
            }
    end
  end
