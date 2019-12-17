class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  require 'panoptes_api'

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
        parsed_jwt = panoptes_api.client.token_contents
        User.where(id: parsed_jwt["id"], login: parsed_jwt["login"]).first_or_create.tap do |user|
          user.display_name = parsed_jwt['dname']

          # Explicitly set user admin accessor if encoded in JWT
          user.admin = parsed_jwt['admin'] == true
        end
      else
        nil
      end
  end

  def set_roles
    return unless current_user

    current_user.roles = panoptes_api.roles current_user.id
  end

  def panoptes_api
    @panoptes_api ||= PanoptesApi.new auth_token
  end

  def auth_token
    return @auth_token if @auth_token

    authorization = request.headers['Authorization']
    @auth_token = authorization.sub(/^Bearer /, '') if authorization.present?
  end

  private

  def jsonapi_meta(resources)
    pagination = jsonapi_pagination_meta(resources)
    { pagination: pagination } if pagination.present?
  end
end
