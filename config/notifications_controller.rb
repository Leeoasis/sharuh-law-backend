class NotificationsController < ApplicationController
  # GET /api/notifications/:user_id
  def index
    user = User.find_by(id: params[:user_id])
    return render json: { error: "User not found" }, status: :not_found unless user

    notifications = Notification.where(user_id: user.id).order(created_at: :desc)
    render json: notifications
  end
end
