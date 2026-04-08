class CoachesController < ApplicationController
  before_action :require_admin_only!
  before_action :set_coach, only: [:edit, :update, :destroy]

  def index
    @coaches = User.coaches
      .where(gym_id: manageable_gyms.select(:id))
      .order(:full_name)
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
      redirect_to coaches_path, notice: "Coach created successfully."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_collections
  end

  def update
    if @coach.update(coach_update_params)
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
    @coach = User.coaches.where(gym_id: manageable_gyms.select(:id)).find(params[:id])
  end

  def load_form_collections
    @gyms = manageable_gyms.order(:name)
  end

  def coach_params
    params.require(:coach).permit(:full_name, :email, :phone_number, :gym_id)
  end

  def coach_update_params
    params.require(:coach).permit(:full_name, :email, :phone_number, :gym_id)
  end
end
