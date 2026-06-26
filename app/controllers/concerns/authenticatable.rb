module Authenticatable
  extend ActiveSupport::Concern

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = nil
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")

    token = header.split(" ", 2).last
    decoded = JsonWebToken.decode(token)
    return nil unless decoded

    @current_user = User.find_by(id: decoded[:user_id])
  end

  def authenticate_user!
    return if current_user

    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
