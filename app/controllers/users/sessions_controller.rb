class Users::SessionsController < Devise::SessionsController
  respond_to :json

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
