class CasesController < ApplicationController
  before_action :set_case, only: [ :show, :update, :destroy, :accept ]
  skip_before_action :verify_authenticity_token, raise: false

  # GET /cases
  def index
    user = User.find(params[:user_id])
    if user.client?
      @cases = user.client_cases
    elsif user.lawyer?
      @cases = user.lawyer_cases
    end
    render json: @cases
  end

  # GET /cases/:id
  def show
    render json: @case
  end

  # POST /cases
  def create
    user = User.find(params[:user_id])
    @case = user.client_cases.build(case_params)

    if @case.save
      notify_matching_lawyers(@case)
      @case.reload # Ensure notifications are loaded

      if @case.notifications.any? { |notification| notification.message.include?("No lawyers match") }
        render json: { message: "No lawyers match your case. Try adjusting the details.", case: @case }, status: :created
      else
        render json: @case, status: :created
      end
    else
      render json: @case.errors, status: :unprocessable_entity
    end
  end

  # PUT /cases/:id
  def update
    if @case.update(case_params)
      render json: @case
    else
      render json: @case.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cases/:id
  def destroy
    @case.destroy
    head :no_content
  end

  # PATCH /cases/:id/accept
  def accept
    lawyer = User.find(params[:lawyer_id])

    if @case.lawyer.nil? # Ensure only one lawyer gets assigned
      @case.update(lawyer: lawyer)
      Notification.create(
        user_id: @case.client_id,
        message: "Your case has been accepted by #{lawyer.name}."
      )
      render json: { message: "You have been assigned to this case." }, status: :ok
    else
      render json: { error: "This case has already been accepted by #{@case.lawyer.name}." }, status: :unprocessable_entity
    end
  end

  private

  def set_case
    user = User.find(params[:user_id])
    @case = if user.client?
              user.client_cases.find(params[:id])
    elsif user.lawyer?
              user.lawyer_cases.find(params[:id])
    end
  end

  def notify_matching_lawyers(case_instance)
    return unless case_instance.persisted? # Ensure case is saved before sending notifications

    preferred_language = case_instance.client&.preferred_language.presence || "English"
    case_title = case_instance.title.presence || "General"

    matching_lawyers = User.where(role: "lawyer")
                           .where("areas_of_expertise ILIKE ?", "%#{case_title}%")
                           .where(preferred_language: preferred_language)
                           .where("experience_years >= ?", 2)

    if matching_lawyers.empty?
      Notification.create!(
        user_id: case_instance.client_id,
        case_id: case_instance.id,
        message: "No lawyers match your case. Try adjusting the details."
      )
    else
      matching_lawyers.each do |lawyer|
        notification = Notification.create!(
          user_id: lawyer.id,
          case_id: case_instance.id,
          message: "A new case matches your expertise."
        )

        NotificationsChannel.broadcast_to(
          lawyer,
          notification.as_json(only: [ :id, :user_id, :case_id, :message, :created_at ])
        )
      end
    end
  rescue => e
    Rails.logger.error("Error in notify_matching_lawyers: #{e.message}")
  end

  def case_params
    params.require(:case).permit(:title, :description, :court, :budget, :caseType)
  end
end
