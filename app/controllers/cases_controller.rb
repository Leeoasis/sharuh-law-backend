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

  def create
    user = User.find(params[:user_id])
    return render json: { error: "Case type is required" }, status: :unprocessable_entity if case_params[:case_type].blank?

    @case = user.client_cases.build(case_params.merge(status: "open"))

    if @case.save
      admin_users = User.where(role: "admin")
      admin_users.each do |admin|
        Notification.create!(
          user_id: admin.id,
          case_id: @case.id,
          message: "New case submitted: #{@case.title}",
          read: false
        )
        NotificationsChannel.broadcast_to(admin, {
          message: "New case submitted: #{@case.title}",
          case_id: @case.id
        })
      end

      render json: @case, include: { lawyer: { only: [:id, :name] } }, status: :created
    else
      render json: @case.errors, status: :unprocessable_entity
    end
  end

  def update
    if params[:case][:lawyer_id].present?
      lawyer = User.find_by(id: params[:case][:lawyer_id], role: 'lawyer')
      return render json: { error: "Lawyer not found" }, status: :not_found unless lawyer

      # ✅ Set status to open (NOT claimed) — lawyer must explicitly accept
      if @case.update(case_params.merge(lawyer_id: lawyer.id, status: 'open'))
        Notification.create!(
          user_id: @case.client_id,
          case_id: @case.id,
          message: "Your case has been assigned to #{lawyer.name}.",
          read: false
        )

        NotificationsChannel.broadcast_to(@case.client, {
          message: "Your case has been assigned to #{lawyer.name}",
          case_id: @case.id
        })

        Notification.create!(
          user_id: lawyer.id,
          case_id: @case.id,
          message: "You have been assigned a new case: #{@case.title}",
          read: false
        )

        NotificationsChannel.broadcast_to(lawyer, {
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

  def destroy
    @case.destroy
    head :no_content
  end

def accept
  lawyer = User.find(params[:lawyer_id])

  if @case.lawyer_id != lawyer.id
    render json: { error: "You are not assigned to this case." }, status: :unauthorized
    return
  end

  if @case.status == "claimed"
    render json: { error: "This case has already been claimed." }, status: :unprocessable_entity
    return
  end

  @case.update!(status: "claimed")

  Notification.create!(
    user_id: @case.client_id,
    message: "Your case has been accepted by #{lawyer.name}.",
    case_id: @case.id
  )

  NotificationsChannel.broadcast_to(@case.client, {
    message: "Your case was accepted by #{lawyer.name}",
    case_id: @case.id
  })

  render json: {
    message: "You have accepted the case.",
    case: @case
  }, status: :ok
end
sa

  def available_cases
    lawyer = User.find_by(id: params[:id], role: 'lawyer')
    return render json: { error: 'Lawyer not found' }, status: :not_found unless lawyer

    open_cases = Case.where(status: "open")

    lawyer_expertise = lawyer.areas_of_expertise.to_s.downcase.split(',').map(&:strip)
    lawyer_courts = lawyer.preferred_court.to_s.downcase.split(',').map(&:strip)

    matching = open_cases.select do |c|
      expertise_match = lawyer_expertise.any? { |exp| exp == c.case_type.to_s.downcase.strip }
      court_match = lawyer_courts.any? { |crt| crt == c.court.to_s.downcase.strip }
      expertise_match && court_match
    end

    render json: matching, include: { lawyer: { only: [:id, :name] } }
  end

  # GET /admin-cases
  def admin_index
    admin = User.find_by(id: params[:user_id], role: "admin")
    return render json: { error: "Unauthorized" }, status: :unauthorized unless admin

    cases = Case.where(lawyer_id: nil, status: 'open')
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
end
