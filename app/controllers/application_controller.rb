class ApplicationController < ActionController::Base
	before_action :authenticate_user!, unless: :devise_controller?
	before_action :configure_permitted_parameters, if: :devise_controller?

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
		devise_parameter_sanitizer.permit(:account_update, keys: [:full_name, :phone_number])
	end

	def require_superadmin!
		return if current_user&.superadmin?

		redirect_to root_path, alert: "Only superadmins can access this section."
	end

	def require_admin_or_superadmin!
		return if current_user&.superadmin? || current_user&.admin?

		redirect_to root_path, alert: "Only admins can access this section."
	end

	def require_admin_only!
		return if current_user&.admin?

		redirect_to dashboard_path, alert: "This CRM section is reserved for admins."
	end

	def require_coach_or_higher!
		return if current_user&.superadmin? || current_user&.admin? || current_user&.coach?

		redirect_to root_path, alert: "Only coaches can access this section."
	end

	def manageable_gyms
		return Gym.all if current_user.superadmin?
		return current_user.managed_gyms if current_user.admin?

		Gym.none
	end

	def after_sign_in_path_for(resource)
		if resource.superadmin? || resource.admin?
			dashboard_path
		else
			sign_out(resource)
			flash[:alert] = "Access is restricted to admins and superadmins."
			new_user_session_path
		end
	end

	def after_sign_out_path_for(_resource_or_scope)
		new_user_session_path
	end
end
