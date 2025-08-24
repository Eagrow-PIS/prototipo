class Api::LeavesController < ApplicationController
  before_action :set_leave, only: [:show, :update, :destroy]

  def index
    @leaves = Leave.all
    render json: @leaves
  end

  def show
    render json: @leave
  end

  def create
    @leave = Leave.new(leave_params)
    if @leave.save
      render json: @leave, status: :created
    else
      render json: @leave.errors.full_messages, status: :unprocessable_content
    end
  end

  def update
    if @leave.update(leave_params)
      render json: @leave
    else
      render json: @leave.errors.full_messages, status: :unprocessable_content
    end
  end

  def destroy
    @leave.destroy
    head :no_content
  end

  private

  def set_leave
    @leave = Leave.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Leave not found" }, status: :not_found
  end

  def leave_params
    params.require(:leave).permit(:start_date, :end_date, :leave_type, :state)
  end
end
