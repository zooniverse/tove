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
      logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
      logger.tagged('DUP_ID') { logger.warn exception }

      Raven.capture_exception(exception) if rand(100) == 1
      error = { status: '400', title: Rack::Utils::HTTP_STATUS_CODES[400] }
      render jsonapi_errors: [error], status: :bad_request
    else
      head :no_content
    end
  end

end
