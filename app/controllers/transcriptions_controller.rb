class TranscriptionsController < ApplicationController
  include JSONAPI::Deserialization

  before_action :status_filter_to_int, only: :index

  def index
    @transcriptions = Transcription.all
    jsonapi_render(@transcriptions, allowed_filters)
  end

  def update
    @transcription = Transcription.find(params[:id])
    raise ActionController::BadRequest if type_invalid?
    @transcription.update!(update_attrs)
    render jsonapi: @transcription
  end

  def show
    @transcription = Transcription.find(params[:id])
    render jsonapi: @transcription
  end

  private

  def update_attrs
    jsonapi_deserialize(params)
  end

  # jsonapi.rb filtering doesn't handle filtering by enum term (e.g. 'ready'),
  # so we must translate status terms to their integer value if they're present
  def status_filter_to_int
    if params[:filter]
      params[:filter].each do |key, value|
        if key.split('_').first == 'status'
          enum_value = Transcription.statuses[value]
          params[:filter][key] = enum_value if enum_value
        end
      end
    end
  end

  def type_invalid?
    params[:data][:type] != "transcriptions"
  end

  def allowed_filters
    [:id, :subject_id, :workflow_id, :group_id, :flagged, :status]
  end
end
