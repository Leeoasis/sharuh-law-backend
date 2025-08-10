class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "NotificationsChannel_#{params[:user_id]}"
  end
end
