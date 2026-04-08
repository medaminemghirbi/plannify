class SettingsController < ApplicationController
  before_action :require_admin_only!
  before_action :set_gym

  def edit
  end

  def update
    if @gym.update(settings_params)
      persist_theme_preference
      persist_locale_preference
      redirect_to edit_settings_path(locale: selected_locale), notice: "Settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_gym
    @gym = current_user.managed_gym
    return if @gym.present?

    redirect_to dashboard_path, alert: "No gym assigned to this admin account yet."
  end

  def settings_params
    params.require(:gym).permit(:name, :address, :currency, :logo, :notifications_enabled, :latitude, :longitude)
  end

  def persist_theme_preference
    theme = params[:theme].to_s
    return unless %w[light dark].include?(theme)

    cookies.permanent[:plannify_theme] = {
      value: theme,
      same_site: :lax
    }
  end

  def persist_locale_preference
    cookies.permanent[:locale] = {
      value: selected_locale,
      same_site: :lax
    }
  end

  def selected_locale
    locale = params[:locale].presence || I18n.locale
    locale = locale.to_s
    return locale if I18n.available_locales.map(&:to_s).include?(locale)

    I18n.default_locale.to_s
  end
end
