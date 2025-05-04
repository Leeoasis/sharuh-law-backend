class CasesController < ApplicationController
  before_action :set_case, only: [:accept]

  # GET /cases?user_id=...
  def index
    user_id = params[:user_id]
    user = User.find_by(id: user_id)

    return render json: { error: "User not found" }, status: :not_found unless user

    if user.lawyer?
      @cases = Case.where(lawyer_id: user.id)
    elsif user.client?
      @cases = Case.where(client_id: user.id)
    else
      return render json: { error: "Invalid role" }, status: :unprocessable_entity
    end

    render json: @cases
  end

  # POST /cases
  def create
    client = User.find_by(id: params[:user_id], role: "client")
    return render json: { error: "Client not found" }, status: :not_found unless client

    new_case = client.client_cases.build(case_params.merge(status: "open"))

    if new_case.save
      matching_lawyers = User.lawyer.where("areas_of_expertise ILIKE ?", "%#{new_case.case_type}%")

      if matching_lawyers.any?
        matching_lawyers.each do |lawyer|
          ActionCable.server.broadcast("NotificationsChannel_#{lawyer.id}", {
            message: "New case: #{new_case.title}",
            case_id: new_case.id
          })
        end
      else
        ActionCable.server.broadcast("NotificationsChannel_#{client.id}", {
          message: "No matching lawyers found for your case."
        })
      end

      render json: { message: "Case created", case: new_case }, status: :created
    else
      render json: { error: new_case.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /cases/:id/accept
  def accept
    lawyer = User.find_by(id: params[:lawyer_id], role: "lawyer")
    return render json: { error: "Lawyer not found" }, status: :not_found unless lawyer

    if @case.claimed?
      return render json: { error: "Case already claimed" }, status: :unprocessable_entity
    end

    @case.update!(lawyer_id: lawyer.id, status: "claimed")

    ActionCable.server.broadcast("NotificationsChannel_#{@case.client_id}", {
      message: "#{lawyer.name} accepted your case '#{@case.title}'"
    })

    User.lawyer.where.not(id: lawyer.id).each do |other_lawyer|
      ActionCable.server.broadcast("NotificationsChannel_#{other_lawyer.id}", {
        message: "Case '#{@case.title}' already claimed."
      })
    end

    render json: { message: "Case successfully claimed." }, status: :ok
  end

  private

  def set_case
    @case = Case.find_by(id: params[:id])
    render json: { error: "Case not found" }, status: :not_found unless @case
  end

  def case_params
    params.require(:case).permit(:title, :description, :court, :budget, :case_type)
  end
end
