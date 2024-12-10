class CasesController < ApplicationController
  before_action :set_case, only: [ :show, :update, :destroy ]
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
      render json: @case, status: :created
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

  private

  def set_case
    user = User.find(params[:user_id])
    @case = if user.client?
              user.client_cases.find(params[:id])
    elsif user.lawyer?
              user.lawyer_cases.find(params[:id])
    end
  end

  def case_params
    params.require(:case).permit(:title, :description, :lawyer_id)
  end
end
