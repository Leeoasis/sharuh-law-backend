class Users::SessionsController < Devise::SessionsController
  respond_to :json

  def destroy
    if current_user
      sign_out(current_user)
    end

    render json: { message: "Logged out successfully" }, status: :ok
  rescue JWT::DecodeError
    render json: { message: "Token already invalid or missing" }, status: :ok
  end

  private

  def respond_with(resource, _opts = {})
    render json: { user: resource, role: resource.role }, status: :ok
  end

  def respond_to_on_destroy
    head :no_content
  end

  def respond_to_on_failure
    render json: { error: "Invalid email or password" }, status: :unauthorized
  end
end
