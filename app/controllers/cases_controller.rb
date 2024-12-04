class CasesController < ApplicationController
  before_action :set_case, only: [:show, :update, :destroy]
  skip_before_action :verify_authenticity_token, raise: false 


  # GET /cases
  def index
    if current_user.client?
      @cases = current_user.client_cases
    elsif current_user.lawyer?
      @cases = current_user.lawyer_cases
    end
    render json: @cases
  end

  # GET /cases/:id
  def show
    render json: @case
  end

  # POST /cases
  def create
    @case = current_user.client_cases.build(case_params)

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
    @case = if current_user.client?
              current_user.client_cases.find(params[:id])
            elsif current_user.lawyer?
              current_user.lawyer_cases.find(params[:id])
            end
  end

  def case_params
    params.require(:case).permit(:title, :description, :lawyer_id)
  end
end