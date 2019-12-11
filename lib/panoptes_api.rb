require 'authenticator'
require 'panoptes/client'

class PanoptesApi
  attr_accessor :client

  def initialize(token)
    @token ||= token
    client
  end

  def roles(user_id)
    { }.tap do |roles|
      response = get_roles(user_id)
      response['project_roles'].map do |role|
        project_id = role['links']['project'].to_i
        roles[project_id] ||= []
        roles[project_id] |= role['roles']
      end
    end
  end

  def project(slug)
    response = client.get('projects', { slug: slug, cards: true })['projects'].first
    { id: response['id'].to_i, slug: response['slug'] }
  end

  def env
    Rails.env.production? ? :production : :staging
  end

  def client
    @client ||= Panoptes::Client.new({
      env: env,
      auth: { token: @token }
    }).panoptes
  end

  def get_roles(user_id)
    client.paginate('project_roles', { user_id: user_id, page_size: 100 })
  end
end
