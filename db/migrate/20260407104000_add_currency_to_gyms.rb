class AddCurrencyToGyms < ActiveRecord::Migration[7.1]
  def change
    add_column :gyms, :currency, :string, null: false, default: "TND"
  end
end