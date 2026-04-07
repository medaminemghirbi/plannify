module ApplicationHelper
	def money_currency_options
		Gym::CURRENCIES.map { |code| [code, code] }
	end

	def format_money(amount, gym: nil, currency: nil)
		code = currency.presence || gym&.currency.presence || "TND"
		return "-" if amount.nil?

		number_to_currency(amount, unit: code, format: "%n %u")
	end
end
