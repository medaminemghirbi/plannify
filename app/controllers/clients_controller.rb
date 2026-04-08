class ClientsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_client, only: [:edit, :update, :destroy]

  def index
    @clients = User.clients
      .where(gym_id: manageable_gyms.select(:id))
      .includes(:groups)
      .order(:full_name)
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
      redirect_to clients_path, notice: "Client created successfully."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_collections
  end

  def update
    if @client.update(client_update_params)
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
    @client = User.clients.where(gym_id: manageable_gyms.select(:id)).find(params[:id])
  end

  def load_form_collections
    @gyms = manageable_gyms.order(:name)
  end

  def client_params
    params.require(:client).permit(:full_name, :email, :phone_number, :gym_id)
  end

  def client_update_params
    params.require(:client).permit(:full_name, :email, :phone_number, :gym_id)
  end
end
