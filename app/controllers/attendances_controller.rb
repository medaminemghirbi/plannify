class AttendancesController < ApplicationController
  before_action :require_admin_only!
  before_action :set_attendance, only: [:edit, :update, :destroy]

  def index
    @attendances = visible_attendances.order(date: :desc)
  end

  def new
    @attendance = Attendance.new(date: Date.current, status: "present")
    load_form_collections
  end

  def create
    @attendance = Attendance.new(attendance_params)

    if @attendance.save
      redirect_to attendances_path, notice: "Attendance recorded successfully."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_collections
  end

  def update
    if @attendance.update(attendance_params)
      redirect_to attendances_path, notice: "Attendance updated successfully."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @attendance.destroy
    redirect_to attendances_path, notice: "Attendance deleted successfully."
  end

  private

  def set_attendance
    @attendance = visible_attendances.find(params[:id])
  end

  def visible_attendances
    scope = Attendance.includes(:client, training_group: [:gym, :coach])

    return scope.joins(training_group: :gym).where(training_groups: { gym_id: manageable_gyms.select(:id) }) if current_user.superadmin? || current_user.admin?
    return scope.joins(:training_group).where(training_groups: { coach_id: current_user.id }) if current_user.coach?

    scope.where(client: current_user)
  end

  def load_form_collections
    if current_user.superadmin? || current_user.admin?
      @training_groups = TrainingGroup.where(gym: manageable_gyms).order(:name)
      @clients = User.clients.joins(:client_gyms).where(client_gyms: { gym_id: manageable_gyms.select(:id) }).order(:full_name).distinct
    elsif current_user.coach?
      @training_groups = TrainingGroup.where(coach: current_user).order(:name)
      @clients = User.clients.joins(:client_gyms).where(client_gyms: { gym_id: @training_groups.select(:gym_id) }).order(:full_name).distinct
    else
      @training_groups = TrainingGroup.none
      @clients = User.where(id: current_user.id)
    end
  end

  def attendance_params
    params.require(:attendance).permit(:client_id, :training_group_id, :date, :status)
  end
end
