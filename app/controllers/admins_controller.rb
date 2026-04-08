class AdminsController < ApplicationController
  before_action :require_superadmin!
  before_action :set_admin_user, only: [:edit, :update, :destroy]

  def index
    @admins = User.admins.includes(:managed_gym).order(:full_name)
  end

  def new
    @admin_user = User.new(role: "admin")
    @admin_user.build_managed_gym
  end

  def create
    @admin_user = User.new(admin_attributes)
    @admin_user.role = "admin"
    @admin_user.confirmed_at ||= Time.current

    ActiveRecord::Base.transaction do
      @admin_user.save!
      @admin_user.create_managed_gym!(company_attributes)
    end

    redirect_to admins_path, notice: "Admin and company created successfully."
  rescue ActiveRecord::RecordInvalid
    @admin_user.build_managed_gym if @admin_user.managed_gym.blank?
    render :new, status: :unprocessable_entity
  end

  def edit
    @admin_user.build_managed_gym if @admin_user.managed_gym.blank?
  end

  def update
    attrs = admin_attributes.to_h
    if attrs["password"].blank?
      attrs.delete("password")
      attrs.delete("password_confirmation")
    end

    ActiveRecord::Base.transaction do
      @admin_user.update!(attrs)
      gym = @admin_user.managed_gym || @admin_user.build_managed_gym
      gym.update!(company_attributes)
    end

    redirect_to admins_path, notice: "Admin and company updated successfully."
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @admin_user.destroy
    redirect_to admins_path, notice: "Admin deleted successfully."
  end

  private

  def set_admin_user
    @admin_user = User.admins.find(params[:id])
  end

  def admin_user_params
    params.require(:user).permit(
      :full_name,
      :email,
      :phone_number,
      :is_enabled,
      :password,
      :password_confirmation,
      :company_name,
      :company_address,
      :company_currency
    )
  end

  def admin_attributes
    admin_user_params.slice(:full_name, :email, :phone_number, :is_enabled, :password, :password_confirmation)
  end

  def company_attributes
    {
      name: admin_user_params[:company_name],
      address: admin_user_params[:company_address],
      currency: admin_user_params[:company_currency].presence || "TND"
    }
  end
end
