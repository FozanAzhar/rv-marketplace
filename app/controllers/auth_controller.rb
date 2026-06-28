# Token-based authentication (JWT). Signup/login return a Bearer token;
# protected endpoints read it from the Authorization header.
class AuthController < ApplicationController  def create
    user = User.new(user_params)

    if user.save
      render json: user_response(user), status: :created
    else
      render_validation_errors(user)
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      render json: user_response(user)
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      token: JsonWebToken.encode(user_id: user.id)
    }
  end
end
