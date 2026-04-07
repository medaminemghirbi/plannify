class CoachesController < ApplicationController
  before_action :require_admin_only!
  before_action :set_coach, only: [:edit, :update, :destroy]

  def index
    @coaches = User.coaches
      .joins(:coach_gyms)
      .where(coach_gyms: { gym_id: manageable_gyms.pluck(:id) })
      .order(:full_name)
      .distinct
  end

  def new
    @coach = User.new(role: "coach")
    load_form_collections
  end

  def create
    @coach = User.new(coach_params)
    @coach.role = "coach"
    @coach.confirmed_at = Time.current

    if @coach.save
      # Assign coach to selected gyms
      gym_ids = params.dig(:coach, :gym_ids) || []
      gym_ids.each do |gym_id|
        CoachGym.find_or_create_by(user_id: @coach.id, gym_id: gym_id)
      end

      redirect_to coaches_path, notice: "Coach created successfully."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_collections
    @coach_gym_ids = @coach.coach_gyms.pluck(:gym_id)
  end

  def update
    if @coach.update(coach_update_params)
      # Update gym assignments
      gym_ids = params.dig(:coach, :gym_ids) || []
      @coach.coach_gyms.destroy_all
      gym_ids.each do |gym_id|
        CoachGym.find_or_create_by(user_id: @coach.id, gym_id: gym_id)
      end

      redirect_to coaches_path, notice: "Coach updated successfully."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @coach.destroy
    redirect_to coaches_path, notice: "Coach deleted successfully."
  end

  private

  def set_coach
    @coach = User.coaches.find(params[:id])
  end

  def load_form_collections
    @gyms = manageable_gyms.order(:name)
  end

  def coach_params
    params.require(:coach).permit(:full_name, :email, :phone_number)
  end

  def coach_update_params
    params.require(:coach).permit(:full_name, :email, :phone_number)
  end
end
