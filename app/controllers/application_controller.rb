class ApplicationController < ActionController::Base
	before_action :authenticate_user!, unless: :devise_controller?
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_action :set_locale

	def default_url_options
		{ locale: I18n.locale }
	end

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
		devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :phone_number])
	end

	def require_superadmin!
		return if current_user&.superadmin?

		redirect_to root_path, alert: I18n.t("alerts.only_superadmins")
	end

	def require_admin_or_superadmin!
		return if current_user&.superadmin? || current_user&.admin?

		redirect_to root_path, alert: I18n.t("alerts.only_admins")
	end

	def require_admin_only!
		return if current_user&.admin?

		redirect_to dashboard_path, alert: I18n.t("alerts.crm_admin_only")
	end

	def require_coach_or_higher!
		return if current_user&.superadmin? || current_user&.admin? || current_user&.coach?

		redirect_to root_path, alert: I18n.t("alerts.only_coaches")
	end

	def manageable_gyms
		return Gym.all if current_user.superadmin?
		return Gym.where(admin_id: current_user.id) if current_user.admin?

		Gym.none
	end

	def after_sign_in_path_for(resource)
		if resource.superadmin? || resource.admin?
			dashboard_path
		else
			sign_out(resource)
			flash[:alert] = I18n.t("alerts.access_restricted")
			new_user_session_path
		end
	end

	def after_sign_out_path_for(_resource_or_scope)
		new_user_session_path
	end

	def set_locale
		requested_locale = params[:locale].presence || cookies[:locale].presence || I18n.default_locale
		locale = requested_locale.to_s
		locale = I18n.default_locale.to_s unless I18n.available_locales.map(&:to_s).include?(locale)

		I18n.locale = locale
		cookies.permanent[:locale] = { value: locale, same_site: :lax }
	end
end
