class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  # GET /api/lawyers
  def lawyers
    @lawyers = User.lawyer.where(search_params)
    render json: @lawyers
  end

  # GET /api/clients
  def clients
    @clients = User.client.where(search_params)
    render json: @clients
  end

  # GET /api/lawyer/:id/clients
  def lawyer_clients
    lawyer = User.find_by(id: params[:id], role: 'lawyer')
    return render json: { error: 'Lawyer not found' }, status: :not_found unless lawyer

    client_ids = Case.where(lawyer_id: lawyer.id).pluck(:client_id).uniq
    clients = User.where(id: client_ids, role: 'client')

    render json: clients
  end

  # PUT /api/user/:id
  def update_profile
    @user = User.find_by(id: params[:id])

    if @user.nil?
      render json: { error: "User not found" }, status: :not_found
      return
    end

    if @user.update(user_params)
      if @user.saved_change_to_approved? && @user.approved?
        LawyerMailer.approval_email(@user).deliver_later
      end

      render json: { message: "Profile updated successfully" }, status: :ok
    else
      logger.error "UPDATE FAILED: #{@user.errors.full_messages}"
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/user/profile/:role/:id
  def profile
    @user = User.find_by(id: params[:id], role: params[:role])

    if @user.nil?
      render json: { error: "User not found" }, status: :not_found
    else
      render json: @user, status: :ok
    end
  end

  private

  def search_params
    params.permit(:areas_of_expertise, :experience_years, :preferred_language, :budget, :license_number)
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :preferred_language,
      :budget,
      :license_number,
      :areas_of_expertise,
      :experience_years,
      :rate,
      :preferred_court,
      :address,
      :phone_number,
      :approved
    )
  end
end
