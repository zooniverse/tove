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
    binding.pry

    @transcription.update!(update_attrs)
    update_transcription_exports(update_attrs) if status_has_changed(update_attrs)

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
        # filter key is comprised of <filterterm>_<relationship>
        # e.g. id_eq, status_in, etc - check if filter term is status
        if key.split('_').first == 'status'
          # split status terms in case there is a list of them
          status_terms = value.split(',')
          status_enum_values = []

          # for each status term, try to convert to enum value,
          # and add to list of converted enum values
          status_terms.each do |term|
            enum_value = Transcription.statuses[term]
            status_enum_values.append(enum_value.to_s) if enum_value
          end

          # if list of converted enum values is not empty,
          # update params to reflect converted values
          unless status_enum_values.empty?
            params[:filter][key] = status_enum_values.join(',')
          end
        end
      end
    end
  end

  def type_invalid?
    params[:data][:type] != "transcriptions"
  end

  def allowed_filters
    [:id, :workflow_id, :group_id, :flagged, :status]
  end


  def status_has_changed(attrs)
    attrs.each do |key, value|
      if key == 'status' && Transcription.statuses[@transcription.status] != value
        return true
      end
    end

    false
  end

  def update_transcription_exports(attrs)
    data_storage = DataExports::DataStorage.new

    if attrs['status'] == 'approved'
      data_storage.export_transcription(@transcription)
    else
      data_storage.delete_transcription_files(@transcription)
    end
  end
end
