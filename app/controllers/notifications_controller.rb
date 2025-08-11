class NotificationsController < ApplicationController
    def index
      user = User.find(params[:user_id])
      render json: user.notifications.order(created_at: :desc)
    end
  end
  