class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  require 'authenticator'
  require 'panoptes_client'

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
    @current_user = if auth_token.present?
        User.from_jwt(Authenticator.from_token(auth_token))
      else
        nil
      end
  end

  def set_roles
    return unless current_user
    current_user.roles = panoptes_client.roles current_user.id
  end

  def panoptes_client
    @panoptes_client ||= PanoptesClient.new auth_token
  end

  def auth_token
    return @auth_token if @auth_token
    authorization = request.headers['Authorization']
    @auth_token = authorization.sub(/^Bearer /, '') if authorization.present?
  end
end
