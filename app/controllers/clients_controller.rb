class ClientsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_client, only: [:edit, :update, :destroy]

  def index
    @clients = User.clients
      .joins(:client_gyms)
      .where(client_gyms: { gym_id: manageable_gyms.pluck(:id) })
      .includes(:groups)
      .order(:full_name)
      .distinct
  end

  def new
    @client = User.new(role: "client")
    load_form_collections
  end

  def create
    @client = User.new(client_params)
    @client.role = "client"
    @client.confirmed_at = Time.current

    if @client.save
      # Assign client to selected gyms
      gym_ids = Array(params.dig(:client, :gym_ids)).reject(&:blank?)
      gym_ids.each do |gym_id|
        ClientGym.find_or_create_by(user_id: @client.id, gym_id: gym_id)
      end

      redirect_to clients_path, notice: "Client created successfully."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_collections
    @client_gym_ids = @client.client_gyms.pluck(:gym_id)
  end

  def update
    if @client.update(client_update_params)
      # Update gym assignments
      gym_ids = Array(params.dig(:client, :gym_ids)).reject(&:blank?)
      @client.client_gyms.destroy_all
      gym_ids.each do |gym_id|
        ClientGym.find_or_create_by(user_id: @client.id, gym_id: gym_id)
      end

      redirect_to clients_path, notice: "Client updated successfully."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: "Client deleted successfully."
  end

  private

  def set_client
    @client = User.clients.find(params[:id])
  end

  def load_form_collections
    @gyms = manageable_gyms.order(:name)
  end

  def client_params
    params.permit(:full_name, :email, :phone_number)
  end

  def client_update_params
    params.permit(:full_name, :email, :phone_number)
  end
end
