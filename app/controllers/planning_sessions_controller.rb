class PlanningSessionsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_planning_session, only: [:edit, :update, :destroy]

  def index
    @planning_sessions = visible_planning_sessions.order(:start_time)
    @planning_events = @planning_sessions.map do |session|
      coach_name = session.training_group.coach&.full_name || "-"
      {
        id: session.id,
        title: "#{session.training_group.name} - Coach: #{coach_name}",
        start: session.start_time.iso8601,
        end: session.end_time.iso8601,
        url: (edit_planning_session_path(session) if current_user.admin? || current_user.superadmin?),
        extendedProps: {
          coach: coach_name,
          gym: session.training_group.gym.name,
          recurrence: session.recurrence.presence || "one-time"
        }
      }
    end
  end

  def new
    @planning_session = PlanningSession.new
    load_form_collections
  end

  def create
    @planning_session = PlanningSession.new(planning_session_params)

    if @planning_session.save
      redirect_to planning_sessions_path, notice: "Planning session created successfully."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_collections
  end

  def update
    if @planning_session.update(planning_session_params)
      respond_to do |format|
        format.html { redirect_to planning_sessions_path, notice: "Planning session updated successfully." }
        format.json { render json: { ok: true } }
      end
    else
      respond_to do |format|
        format.html do
          load_form_collections
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: { ok: false, errors: @planning_session.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @planning_session.destroy
    redirect_to planning_sessions_path, notice: "Planning session deleted successfully."
  end

  private

  def set_planning_session
    @planning_session = visible_planning_sessions.find(params[:id])
  end

  def visible_planning_sessions
    scope = PlanningSession.includes(training_group: [:gym, :coach])

    return scope.joins(training_group: :gym).where(training_groups: { gym_id: manageable_gyms.select(:id) }) if current_user.superadmin? || current_user.admin?
    return scope.joins(:training_group).where(training_groups: { coach_id: current_user.id }) if current_user.coach?

    scope.joins(training_group: :gym).where(training_groups: { gym_id: current_user.gym_id })
  end

  def load_form_collections
    @training_groups = if current_user.superadmin? || current_user.admin?
      TrainingGroup.where(gym: manageable_gyms).where.not(coach_id: nil).order(:name)
    elsif current_user.coach?
      TrainingGroup.where(coach: current_user).where.not(coach_id: nil).order(:name)
    else
      TrainingGroup.none
    end
  end

  def planning_session_params
    params.require(:planning_session).permit(:training_group_id, :start_time, :end_time, :recurrence)
  end
end
