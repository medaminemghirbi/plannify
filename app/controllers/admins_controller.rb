class AdminsController < ApplicationController
  before_action :require_superadmin!
  before_action :set_admin_user, only: [:edit, :update, :destroy]

  def index
    @admins = User.admins.order(:full_name)
  end

  def new
    @admin_user = User.new(role: "admin")
  end

  def create
    @admin_user = User.new(admin_user_params)
    @admin_user.role = "admin"
    @admin_user.confirmed_at ||= Time.current

    if @admin_user.save
      redirect_to admins_path, notice: "Admin created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = admin_user_params.to_h
    if attrs["password"].blank?
      attrs.delete("password")
      attrs.delete("password_confirmation")
    end

    if @admin_user.update(attrs)
      redirect_to admins_path, notice: "Admin updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
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
    params.require(:user).permit(:full_name, :email, :phone_number, :password, :password_confirmation)
  end
end
