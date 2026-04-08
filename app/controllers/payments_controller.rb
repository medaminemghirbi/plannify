class PaymentsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_payment, only: [:edit, :update, :destroy]

  PAGE_SIZES = [5, 10, 100].freeze

  def index
    @selected_month = params[:month].presence
    @selected_year = params[:year].presence&.to_i
    @selected_group_id = params[:group_id].presence
    @selected_page_size = params[:per_page].presence&.to_i || PAGE_SIZES.first
    @selected_page_size = PAGE_SIZES.include?(@selected_page_size) ? @selected_page_size : PAGE_SIZES.first
    @current_page = params[:page].presence&.to_i || 1

    scope = filtered_payments_scope
    @payments_count = scope.count
    @total_pages = (@payments_count.to_f / @selected_page_size).ceil
    @current_page = 1 if @current_page < 1
    @current_page = @total_pages if @total_pages.positive? && @current_page > @total_pages
    @payments = scope
      .order(starts_on: :desc)
      .offset((@current_page - 1) * @selected_page_size)
      .limit(@selected_page_size)

    @revenue_total = scope.sum(:amount)
    @default_currency = manageable_gyms.reorder(nil).limit(1).pick(:currency) || "TND"
    @available_years = visible_payment_base_scope
      .reorder(nil)
      .pluck(Arel.sql("DISTINCT EXTRACT(YEAR FROM starts_on)::integer"))
      .sort
      .reverse
    @month_options = Date::MONTHNAMES.compact.each_with_index.map { |month, index| [month, index + 1] }
    @year_options = (@available_years.presence || [Date.current.year]).sort.reverse
    @group_options = TrainingGroup.where(gym: manageable_gyms).order(:name).pluck(:name, :id)
  end

  def new
    @payment = Payment.new(starts_on: Date.current, duration_months: 1, status: "pending")
    load_collections
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.created_by = current_user

    if @payment.save
      redirect_to payments_path, notice: "Payment created successfully."
    else
      load_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_collections
  end

  def update
    if @payment.update(payment_params)
      redirect_to payments_path, notice: "Payment updated successfully."
    else
      load_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payment.destroy
    redirect_to payments_path, notice: "Payment deleted successfully."
  end

  private

  def set_payment
    @payment = visible_payments.find(params[:id])
  end

  def visible_payments
    Payment.where(id: visible_payment_base_scope.select(:id).distinct)
      .includes(:receipt, :created_by, client: :gym)
  end

  def visible_payment_base_scope
    Payment
      .joins(:client)
      .where(users: { gym_id: manageable_gyms.select(:id) })
  end

  def filtered_payments_scope
    scope = visible_payments
    scope = scope.where("EXTRACT(MONTH FROM starts_on) = ?", @selected_month.to_i) if @selected_month.present?
    scope = scope.where("EXTRACT(YEAR FROM starts_on) = ?", @selected_year) if @selected_year.present?
    if @selected_group_id.present?
      group_client_ids = GroupMembership.where(training_group_id: @selected_group_id).select(:client_id)
      scope = scope.where(client_id: group_client_ids)
    end
    scope
  end

  def load_collections
    @clients = User.clients
      .where(gym_id: manageable_gyms.select(:id))
      .order(:full_name)
    @duration_options = [["1 month", 1], ["3 months", 3], ["1 year", 12]]
    @status_options = Payment::STATUSES.map { |status| [status.humanize, status] }
  end

  def payment_params
    params.require(:payment).permit(:client_id, :amount, :starts_on, :duration_months, :status, :notes)
  end
end
