class TranscriptionsController < ApplicationController
  include JSONAPI::Deserialization

  class NoExportableTranscriptionsError < StandardError; end

  before_action :status_filter_to_int, only: :index

  def index
    @transcriptions = policy_scope(Transcription)
    jsonapi_render(@transcriptions, allowed_filters)
  end

  def show
    @transcription = Transcription.find(params[:id])
    authorize @transcription
    render jsonapi: @transcription
  end

  def update
    @transcription = Transcription.find(params[:id])
    raise ActionController::BadRequest if type_invalid?
    raise ActionController::BadRequest unless whitelisted_attributes?

    if approving?
      authorize @transcription, :approve?
    else
      authorize @transcription
    end

    update_attrs['updated_by'] = current_user.login
    @transcription.update!(update_attrs)

    if @transcription.status_previously_changed?
      if approving?
        upload_files_to_storage
      else
        remove_files_from_storage
      end
    end

    render jsonapi: @transcription
  end

  def export
    @transcription = Transcription.find(params[:id])
    authorize @transcription

    data_storage = DataExports::DataStorage.new
    data_storage.zip_transcription_files(@transcription) do |zip_file|
      send_export_file zip_file
    end
  end

  def export_group
    @transcriptions = policy_scope([:export, Transcription]).where(group_id: params[:group_id])

    if @transcriptions.empty?
      raise NoExportableTranscriptionsError.new("No exportable transcriptions found for group id '#{params[:group_id]}'")
    end

    data_storage = DataExports::DataStorage.new
    data_storage.zip_group_files(@transcriptions) do |zip_file|
      send_export_file zip_file
    end
  end

  private

  def update_attrs
    @update_attrs ||= jsonapi_deserialize(params)
  end

  # Ransack filtering doesn't handle filtering by enum term (e.g. 'ready'),
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

  def whitelisted_attributes?
    update_attrs.keys.all? { |key| update_attr_whitelist.include? key }
  end

  def approving?
    update_attrs["status"] == "approved"
  end

  def allowed_filters
    [:id, :workflow_id, :group_id, :flagged, :status]
  end

  def upload_files_to_storage
    file_generator = DataExports::TranscriptionFileGenerator.new(@transcription)
    file_generator.generate_transcription_files.each do |temp_file|
      # get filename without the temfile's randomly generated unique string
      basename = File.basename(temp_file)
      filename = basename.split('-').first + File.extname(basename)
      @transcription.files.attach(io: temp_file, filename: filename)

      temp_file.close
      temp_file.unlink
    end
  end

  def remove_files_from_storage
    @transcription.files.map(&:purge)
  end

  def update_attr_whitelist
    ["flagged", "text", "status"]
  end
end
