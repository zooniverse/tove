class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  attr_reader :current_user, :auth_token
  before_action :set_user

  include ErrorExtender
  include JSONAPI::Pagination
  include JSONAPI::Filtering

  def jsonapi_render(collection, filters)
    jsonapi_filter(collection, filters) do |filtered|
      jsonapi_paginate(filtered.result) do |paginated|
        render jsonapi: paginated
      end
    end
  end

  def set_user
    return nil unless auth_token.present?

    @current_user = User.where(
                      id: panoptes.client.authenticated_user_id,
                      login: panoptes.client.authenticated_user_login
                    ).first_or_create.tap do |user|
                      user.display_name = panoptes.client.authenticated_user_display_name

                      # Explicitly set user admin accessor if encoded in JWT
                      user.admin = panoptes.client.authenticated_admin?
                    end

    if needs_roles_refresh?
      set_roles
    end
  end

  def set_roles
    return unless current_user

    current_user.update(roles: panoptes.roles(current_user.id), roles_refreshed_at: Time.now)
  end

  def panoptes
    @panoptes_api ||= PanoptesApi.new auth_token
  end

  def auth_token
    return @auth_token if @auth_token

    authorization = request.headers['Authorization']
    @auth_token = authorization.sub(/^Bearer /, '') if authorization.present?
  end

  def needs_roles_refresh?
    current_user.roles.nil? || current_user.roles_refreshed_at < panoptes.token_created_at
  end

  private

  def jsonapi_meta(resources)
    pagination = jsonapi_pagination_meta(resources)
    { pagination: pagination } if pagination.present?
  end
end
