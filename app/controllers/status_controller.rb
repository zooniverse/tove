class StatusController < ApplicationController
  def show
    @status = ApplicationStatus.new
    render json: @status
  end
end
