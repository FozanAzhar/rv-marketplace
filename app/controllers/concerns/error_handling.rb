# Consistent JSON error responses across all API controllers.
module ErrorHandling  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  end

  private

  def record_not_found(_exception)
    render json: { error: "Record not found" }, status: :not_found
  end

  def parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def record_invalid(exception)
    render_validation_errors(exception.record)
  end

  def render_validation_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
