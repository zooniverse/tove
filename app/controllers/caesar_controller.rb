class CaesarController < ActionController::Base
  include JSONAPI::Errors
  protect_from_forgery unless: -> { request.format.json? }

  def import
    begin
      importer = CaesarImporter.new(
        id: params[:id],
        reducible: params[:reducible],
        data: params[:data],
        subject: params[:subject]
      )
      importer.process
    rescue => exception
      Raven.capture_exception(exception)
      error = { status: '400', title: Rack::Utils::HTTP_STATUS_CODES[400] }
      render jsonapi_errors: [error], status: :bad_request
    else
      head :no_content
    end
  end

end
