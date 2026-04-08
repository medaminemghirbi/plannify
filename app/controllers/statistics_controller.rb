class StatisticsController < ApplicationController
  before_action :require_admin_only!

  def index
    gyms_scope = manageable_gyms
    gyms = gyms_scope.order(:name)
    @statistics_currency = gyms_scope.reorder(nil).limit(1).pick(:currency) || "TND"

    gym_names_by_id = gyms.pluck(:id, :name).to_h

    @clients_per_gym = User.clients.where(gym_id: gyms_scope.select(:id))
      .group(:gym_id).count
      .transform_keys { |gym_id| gym_names_by_id[gym_id] || "Unknown" }

    @sessions_per_gym = PlanningSession.joins(:training_group)
      .where(training_groups: { gym_id: gyms_scope.select(:id) })
      .group("training_groups.gym_id").count
      .transform_keys { |gym_id| gym_names_by_id[gym_id] || "Unknown" }

    @payments_by_status = Payment.joins(:client)
      .where(users: { gym_id: gyms_scope.select(:id) })
      .group(:status).count

    months = (0..5).to_a.reverse.map { |offset| Date.current.beginning_of_month - offset.months }
    @monthly_revenue_labels = months.map { |date| date.strftime("%b %Y") }
    @monthly_revenue_values = months.map do |month_start|
      month_end = month_start.end_of_month
      Payment.joins(:client)
        .where(users: { gym_id: gyms_scope.select(:id) })
        .where(starts_on: month_start..month_end)
        .sum(:amount).to_f
    end
  end
end
