class AdminTutorialsController < ApplicationController
  before_action :require_admin_only!

  def show
    @checklist_items = [
      {
        title: t("admin_tutorial.steps.setup_gym.title"),
        description: t("admin_tutorial.steps.setup_gym.description"),
        cta: t("admin_tutorial.steps.setup_gym.cta"),
        path: edit_settings_path
      },
      {
        title: t("admin_tutorial.steps.add_coaches.title"),
        description: t("admin_tutorial.steps.add_coaches.description"),
        cta: t("admin_tutorial.steps.add_coaches.cta"),
        path: coaches_path
      },
      {
        title: t("admin_tutorial.steps.add_clients.title"),
        description: t("admin_tutorial.steps.add_clients.description"),
        cta: t("admin_tutorial.steps.add_clients.cta"),
        path: clients_path
      },
      {
        title: t("admin_tutorial.steps.create_groups.title"),
        description: t("admin_tutorial.steps.create_groups.description"),
        cta: t("admin_tutorial.steps.create_groups.cta"),
        path: training_groups_path
      },
      {
        title: t("admin_tutorial.steps.plan_sessions.title"),
        description: t("admin_tutorial.steps.plan_sessions.description"),
        cta: t("admin_tutorial.steps.plan_sessions.cta"),
        path: planning_sessions_path
      },
      {
        title: t("admin_tutorial.steps.track_attendance.title"),
        description: t("admin_tutorial.steps.track_attendance.description"),
        cta: t("admin_tutorial.steps.track_attendance.cta"),
        path: attendances_path
      },
      {
        title: t("admin_tutorial.steps.handle_payments.title"),
        description: t("admin_tutorial.steps.handle_payments.description"),
        cta: t("admin_tutorial.steps.handle_payments.cta"),
        path: payments_path
      },
      {
        title: t("admin_tutorial.steps.upload_documents.title"),
        description: t("admin_tutorial.steps.upload_documents.description"),
        cta: t("admin_tutorial.steps.upload_documents.cta"),
        path: documents_path
      }
    ]
  end
end
