class StatusController < ApplicationController
  def show
    skip_authorization
    @status = ApplicationStatus.new
    render json: @status
  end
end
