class CasesController < ApplicationController
  before_action :set_case, only: [:show, :update, :destroy, :accept]
  skip_before_action :verify_authenticity_token, raise: false

  # GET /users/:user_id/cases
  def index
    user = User.find(params[:user_id])
    @cases = user.client? ? user.client_cases : user.lawyer_cases
    render json: @cases, include: { lawyer: { only: [:id, :name, :email] } }
  end

  # GET /users/:user_id/cases/:id
  def show
    render json: @case, include: { lawyer: { only: [:id, :name, :email] } }
  end

  # POST /users/:user_id/cases/check_lawyers
  def check_lawyers
    user = User.find(params[:user_id])
    @case = user.client_cases.build(case_params)
    matching_lawyers = find_matching_lawyers(@case)

    if matching_lawyers.empty?
      render json: { message: "No lawyers match your case." }, status: :ok
    else
      render json: { message: "Matching lawyers found.", lawyers: matching_lawyers }, status: :ok
    end
  end

  # POST /users/:user_id/cases
  def create
    user = User.find(params[:user_id])
    return render json: { error: "Case type is required" }, status: :unprocessable_entity if case_params[:case_type].blank?

    @case = user.client_cases.build(case_params.merge(status: "open"))

    if @case.save
      # Notify admins
      User.where(role: "admin").each do |admin|
        Notification.create!(
          user_id: admin.id,
          case_id: @case.id,
          message: "New case submitted: #{@case.title}",
          read: false
        )
        safe_broadcast(admin, {
          message: "New case submitted: #{@case.title}",
          case_id: @case.id
        })
      end

      render json: @case, include: { lawyer: { only: [:id, :name] } }, status: :created
    else
      render json: @case.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/:user_id/cases/:id
  def update
    if params[:case][:lawyer_id].present?
      lawyer = User.find_by(id: params[:case][:lawyer_id], role: "lawyer")
      return render json: { error: "Lawyer not found" }, status: :not_found unless lawyer

      if @case.update(case_params.merge(lawyer_id: lawyer.id, status: "open"))
        # Notify client
        Notification.create!(
          user_id: @case.client_id,
          case_id: @case.id,
          message: "Your case has been assigned to #{lawyer.name}.",
          read: false
        )
        safe_broadcast(@case.client, {
          message: "Your case has been assigned to #{lawyer.name}",
          case_id: @case.id
        })

        # Notify lawyer
        Notification.create!(
          user_id: lawyer.id,
          case_id: @case.id,
          message: "You have been assigned a new case: #{@case.title}",
          read: false
        )
        safe_broadcast(lawyer, {
          message: "You have been assigned a new case: #{@case.title}",
          case_id: @case.id
        })

        render json: @case, include: { lawyer: { only: [:id, :name] } }
      else
        render json: @case.errors, status: :unprocessable_entity
      end
    else
      if @case.update(case_params)
        render json: @case
      else
        render json: @case.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /users/:user_id/cases/:id
  def destroy
    @case.destroy
    head :no_content
  end

  # POST /cases/:id/accept
  def accept
    lawyer = User.find(params[:lawyer_id])

    if @case.lawyer_id != lawyer.id
      return render json: { error: "You are not assigned to this case." }, status: :unauthorized
    end

    if @case.status == "claimed"
      return render json: { error: "This case has already been claimed." }, status: :unprocessable_entity
    end

    @case.update!(status: "claimed")

    Notification.create!(
      user_id: @case.client_id,
      message: "Your case has been accepted by #{lawyer.name}.",
      case_id: @case.id
    )
    safe_broadcast(@case.client, {
      message: "Your case was accepted by #{lawyer.name}",
      case_id: @case.id
    })

    render json: {
      message: "You have accepted the case.",
      case: @case
    }, status: :ok
  end

  # GET /users/:id/available_cases
  def available_cases
    lawyer = User.find_by(id: params[:id], role: "lawyer")
    return render json: { error: "Lawyer not found" }, status: :not_found unless lawyer

    assigned = Case.where(lawyer_id: lawyer.id, status: "open")
    render json: assigned, include: { client: { only: [:id, :name, :email] } }
  end

  # GET /admin-cases
  def admin_index
    admin = User.find_by(id: params[:user_id], role: "admin")
    return render json: { error: "Unauthorized" }, status: :unauthorized unless admin

    cases = Case.where(lawyer_id: nil, status: "open")
    render json: cases, include: { client: { only: [:id, :name, :email] } }
  end

  private

  def set_case
    if params[:user_id]
      user = User.find(params[:user_id])

      if user.client?
        @case = user.client_cases.find(params[:id])
      elsif user.lawyer?
        @case = user.lawyer_cases.find(params[:id])
      else
        @case = Case.find(params[:id])
      end
    else
      @case = Case.find(params[:id])
    end
  end

  def find_matching_lawyers(case_instance)
    User.where(role: "lawyer")
        .where("areas_of_expertise ILIKE ?", "%#{case_instance.case_type}%")
        .where("preferred_court ILIKE ?", "%#{case_instance.court}%")
        .where("rate <= ?", case_instance.budget)
  end

  def case_params
    params.require(:case).permit(
      :title,
      :description,
      :court,
      :budget,
      :case_type,
      :fee,
      :commission,
      :lawyer_id
    )
  end

  # Broadcast wrapper (so Redis errors don’t break the request)
  def safe_broadcast(user, payload)
    NotificationsChannel.broadcast_to(user, payload)
  rescue => e
    Rails.logger.error "Broadcast failed: #{e.message}"
  end
end
