class TrainingGroupsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_training_group, only: [:show, :edit, :update, :destroy, :add_member, :remove_member]

  def index
    @training_groups = visible_training_groups.order(:name)
  end

  def show
    @memberships = @training_group.group_memberships.includes(:client).order(created_at: :desc)
    @membership_by_client_id = @memberships.index_by(&:client_id)
    @members = @memberships.map(&:client)
    @member_count = @memberships.size
    @available_clients = available_clients_for_group
  end

  def new
    @training_group = TrainingGroup.new
    load_form_collections
  end

  def create
    @training_group = TrainingGroup.new(training_group_params)

    if @training_group.save
      redirect_to @training_group, notice: "Training group created successfully."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_collections
  end

  def update
    if @training_group.update(training_group_params)
      redirect_to @training_group, notice: "Training group updated successfully."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @training_group.destroy
    redirect_to training_groups_path, notice: "Training group deleted successfully."
  end

  def add_member
    client = available_clients_for_group.find(params[:client_id])
    membership = @training_group.group_memberships.build(client: client)

    if membership.save
      redirect_to @training_group, notice: "Client added to group successfully."
    else
      redirect_to @training_group, alert: "Failed to add client to group."
    end
  end

  def remove_member
    membership = @training_group.group_memberships.find(params[:membership_id])
    client_name = membership.client.full_name
    membership.destroy
    redirect_to @training_group, notice: "#{client_name} removed from group successfully."
  end

  private

  def set_training_group
    @training_group = visible_training_groups.find(params[:id])
  end

  def visible_training_groups

    return TrainingGroup.where(gym: manageable_gyms).includes(:gym, :coach) if current_user.superadmin? || current_user.admin?
    return TrainingGroup.where(coach: current_user).includes(:gym, :coach) if current_user.coach?

    TrainingGroup.joins(:gym).where(gyms: { id: current_user.gym_id }).includes(:gym, :coach)
  end

  def available_clients_for_group
    gym_id = @training_group.gym_id
    already_in_group = @training_group.clients.pluck(:id)
    User.clients.where(gym_id: gym_id).where.not(id: already_in_group).order(:created_at)
  end

  def load_form_collections
    @gyms = manageable_gyms.order(:name)
    @coaches = User.coaches.where(gym_id: manageable_gyms.select(:id)).order(:created_at)
  end

  def training_group_params
    params.require(:training_group).permit(:name, :gym_id, :coach_id, :capacity)
  end
end
