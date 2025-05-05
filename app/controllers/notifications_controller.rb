# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  def index
    user = User.find(params[:user_id])
    notifications = user.notifications.order(created_at: :desc)
    render json: notifications
  end
end
