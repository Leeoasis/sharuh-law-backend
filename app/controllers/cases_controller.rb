class CasesController < ApplicationController
  before_action :set_case, only: [:show, :update, :destroy, :accept]
  skip_before_action :verify_authenticity_token, raise: false

  # GET /users/:user_id/cases
  def index
    user = User.find(params[:user_id])
    if user.client?
      @cases = user.client_cases
    elsif user.lawyer?
      @cases = user.lawyer_cases
    end

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
      render json: { message: "No lawyers match your case. Try adjusting the details." }, status: :ok
    else
      render json: { message: "Matching lawyers found.", lawyers: matching_lawyers }, status: :ok
    end
  end

  # POST /users/:user_id/cases
  def create
    user = User.find(params[:user_id])
    @case = user.client_cases.build(case_params.merge(status: "open"))

    if @case.save
      render json: @case, status: :created
    else
      render json: @case.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/:user_id/cases/:id
  def update
    if @case.update(case_params)
      render json: @case
    else
      render json: @case.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/cases/:id
  def destroy
    @case.destroy
    head :no_content
  end

  # ✅ PATCH or POST /cases/:id/accept
  def accept
    lawyer = User.find(params[:lawyer_id])

    if @case.lawyer.nil?
      @case.update(lawyer: lawyer, status: "claimed")

      Notification.create(
        user_id: @case.client_id,
        message: "Your case has been accepted by #{lawyer.name}."
      )

      render json: {
        message: "You have been assigned to this case.",
        case: @case
      }, status: :ok
    else
      render json: {
        error: "This case has already been accepted by #{@case.lawyer.name}."
      }, status: :unprocessable_entity
    end
  end

  # GET /api/lawyer/:id/available_cases
  def available_cases
    lawyer = User.find_by(id: params[:id], role: 'lawyer')
    return render json: { error: 'Lawyer not found' }, status: :not_found unless lawyer

    open_cases = Case.where(lawyer_id: nil, status: "open")

    lawyer_expertise = lawyer.areas_of_expertise.to_s.downcase.split(',').map(&:strip)
    lawyer_courts = lawyer.preferred_court.to_s.downcase.split(',').map(&:strip)

    matching = open_cases.select do |c|
      expertise_match = lawyer_expertise.any? { |exp| exp == c.case_type.to_s.downcase.strip }
      court_match = lawyer_courts.any? { |crt| crt == c.court.to_s.downcase.strip }

      expertise_match && court_match
    end

    render json: matching
  end

  private

  # ✅ Now supports both nested and top-level routes
  def set_case
    if params[:user_id]
      user = User.find(params[:user_id])
      @case = if user.client?
                user.client_cases.find(params[:id])
              elsif user.lawyer?
                user.lawyer_cases.find(params[:id])
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
    params.require(:case).permit(:title, :description, :court, :budget, :case_type)
  end
end
