class GymsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_gym, only: [:show, :edit, :update, :destroy]

  def index
    @gyms = manageable_gyms.order(:name)
  end

  def show
  end

  def new
    @gym = Gym.new
  end

  def create
    @gym = Gym.new(gym_params)
    @gym.admin = current_user if current_user.admin?

    if @gym.save
      redirect_to @gym, notice: "Gym created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @gym.update(gym_params)
      redirect_to @gym, notice: "Gym updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gym.destroy
    redirect_to gyms_path, notice: "Gym deleted successfully."
  end

  private

  def set_gym
    @gym = manageable_gyms.find(params[:id])
  end

  def gym_params
    permitted = [:name, :address, :currency]
    permitted << :admin_id if current_user.superadmin?
    params.require(:gym).permit(*permitted, :logo)
  end
end
