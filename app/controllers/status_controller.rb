class StatusController < ApplicationController
  def show
    @status = ApplicationStatus.new
    render jsonapi: @status
  end
end
