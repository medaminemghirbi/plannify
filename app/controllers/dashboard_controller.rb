class DashboardController < ApplicationController
  before_action :require_admin_or_superadmin!

  def index
    if current_user.superadmin?
      @admins_count = User.admins.count
      @gyms_count = Gym.count
      @recent_admins = User.admins.order(created_at: :desc).limit(8)
    else
      @gyms_count = accessible_gyms.count
      gym_ids = accessible_gyms.select(:id)
      @dashboard_currency = accessible_gyms.reorder(nil).limit(1).pick(:currency) || "TND"
      @coaches_count = User.coaches.where(gym_id: gym_ids).count
      @clients_count = User.clients.where(gym_id: gym_ids).count
      @groups_count = TrainingGroup.where(gym: accessible_gyms).count
      @sessions_count = PlanningSession.joins(training_group: :gym).where(training_groups: { gym_id: accessible_gyms.select(:id) }).count
      @monthly_revenue = Payment.joins(:client)
        .where(users: { gym_id: gym_ids })
        .where(starts_on: Date.current.beginning_of_month..Date.current.end_of_month)
        .sum(:amount)
    end
  end

  private

  def accessible_gyms
    return Gym.all if current_user.superadmin?
    return Gym.where(admin_id: current_user.id) if current_user.admin?

    Gym.none
  end
end
