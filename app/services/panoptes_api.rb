require 'panoptes/client'

class PanoptesApi
  attr_accessor :client

  delegate :authenticated_admin?,
           :authenticated_user_id,
           :authenticated_user_login,
           :authenticated_user_display_name,
           :token_expiry, to: :client

  def initialize(token:, admin:)
    @auth = if admin
      {
        client_id: Rails.application.credentials.panoptes_client_id,
        client_secret: Rails.application.credentials.panoptes_client_secret
      }
    else
      { token: token }
    end
    client
  end

  def roles(user_id)
    { }.tap do |roles|
      response = get_roles(user_id)
      response['project_roles'].map do |role|
        project_id = role['links']['project']
        roles[project_id] ||= []
        roles[project_id] |= role['roles']
      end
    end
  end

  def project(slug)
    response = api.get('projects', { slug: slug, cards: true })['projects'].first
    { id: response['id'].to_i, slug: response['slug'] }
  end

  def workflow(id, include_project=nil)
    query = { id: id }
    response = if include_project
      query[:include] = 'project'
      get_workflow_with_project(query)
    else
      get_workflow(query)
    end
    response
  end

  def env
    Rails.env.production? ? :production : :staging
  end

  def client
    @client ||= Panoptes::Client.new({
      env: env,
      auth: @auth
    })
  end

  def token_created_at
    token_expiry - ENV.fetch("TOKEN_VALIDITY_TIME", "2").to_i.hours
  end

  def api
    client.panoptes
  end

  def get_roles(user_id)
    api.paginate('project_roles', { user_id: user_id, page_size: 100 })
  end

  private

  def get_workflow_with_project(query)
    response = api.get('workflows', query)
    workflow = response['workflows'].first
    project = response['linked']['projects'].first

    {
      id: workflow['id'].to_i,
      display_name: workflow['display_name'],
      project: {
        id: project['id'].to_i,
        slug: project['slug']
      }
    }
  end

  def get_workflow(query)
    response = api.get('workflows', query)['workflows'].first
    { id: response['id'].to_i, display_name: response['display_name'] }
  end
end
