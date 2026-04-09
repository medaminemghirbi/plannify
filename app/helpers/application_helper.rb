module ApplicationHelper
	def locale_options
		[
			[I18n.t("language.names.en"), "en"],
			[I18n.t("language.names.fr"), "fr"],
			[I18n.t("language.names.ar_tn"), "ar-TN"]
		]
	end

	def rtl_locale?
		I18n.locale.to_s.start_with?("ar")
	end

	def sidebar_locked?
		current_user.present? && !current_user.is_enabled?
	end

	def sidebar_lock_icon
		content_tag(:span, class: "ml-2 inline-flex items-center gap-1 text-xs font-semibold uppercase tracking-wide text-amber-600", aria: { label: t("admins.locked") }) do
			concat(content_tag(:span, "🔒", aria: { hidden: true }))
			concat(content_tag(:span, t("admins.locked"), class: "sr-only"))
		end
	end

	def money_currency_options
		Gym::CURRENCIES.map { |code| [code, code] }
	end

	def format_money(amount, gym: nil, currency: nil)
		code = currency.presence || gym&.currency.presence || "TND"
		return "-" if amount.nil?

		number_to_currency(amount, unit: code, format: "%n %u")
	end
end
