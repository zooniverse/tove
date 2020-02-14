class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery unless: -> { request.format.json? }

  attr_reader :current_user, :auth_token
  before_action :set_user
  after_action :verify_authorized, except: [:index, :export_group]
  after_action :verify_policy_scoped, only: [:index]

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
                      id: panoptes.authenticated_user_id,
                      login: panoptes.authenticated_user_login
                    ).first_or_initialize

    set_roles if needs_roles_refresh?
    set_admin if admin_status_changed?
    set_name if display_name_changed?
    save_user! if user_changed?
  end

  def set_roles
    return unless current_user
    current_user.roles = panoptes.roles(current_user.id)
    current_user.roles_refreshed_at = Time.now
  end

  def set_admin
    current_user.admin = panoptes.authenticated_admin?
  end

  def set_name
    current_user.display_name = panoptes.authenticated_user_display_name
  end

  def save_user!
    current_user.save!
  end

  def panoptes
    @panoptes_api ||= UserPanoptesApi.new(auth_token)
  end

  def auth_token
    return @auth_token if @auth_token

    authorization = request.headers['Authorization']
    @auth_token = authorization.sub(/^Bearer /, '') if authorization.present?
  end

  def needs_roles_refresh?
    current_user.roles.nil? || current_user.roles_refreshed_at < panoptes.token_created_at
  end

  def admin_status_changed?
    current_user.admin != panoptes.authenticated_admin?
  end

  def display_name_changed?
    current_user.display_name != panoptes.authenticated_user_display_name
  end

  def user_changed?
    needs_roles_refresh? || admin_status_changed? || display_name_changed?
  end

  private

  def jsonapi_meta(resources)
    pagination = jsonapi_pagination_meta(resources)
    { pagination: pagination } if pagination.present?
  end

  def send_export_file(zip_file)
    File.open(zip_file, 'r') do |f|
      send_data f.read, filename: 'export.zip', type: 'application/zip'
    end
  end
end
