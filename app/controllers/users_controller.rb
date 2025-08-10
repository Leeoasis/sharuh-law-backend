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
    lawyer = User.find_by(id: params[:id], role: "lawyer")
    return render json: { error: "Lawyer not found" }, status: :not_found unless lawyer

    client_ids = Case.where(lawyer_id: lawyer.id).pluck(:client_id).uniq
    clients = User.where(id: client_ids, role: "client")
    render json: clients
  end

  # PUT /api/user/:id
  def update_profile
    @user = User.find_by(id: params[:id])
    return render json: { error: "User not found" }, status: :not_found unless @user

    if @user.update(user_params)
      render json: { message: "Profile updated successfully" }, status: :ok
    else
      logger.error "UPDATE FAILED: #{@user.errors.full_messages}"
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/user/profile/:role/:id
  def profile
    @user = User.find_by(id: params[:id], role: params[:role])
    if @user
      render json: @user, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  private

  def search_params
    params.permit(:name, :email)
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :role,
      :admission_enrollment_order,
      :good_standing_letter,
      :fidelity_fund_certificate,
      :id_document,
      :practice_address,
      :preferred_court,
      :areas_of_expertise,
      :experience_years,
      :rate,
      :license_number,
      :preferred_language,
      :address,
      :phone_number,
      :approved,
      :engagement_form,
      :client_id_document,
      :client_proof_of_address
    )
  end
end
