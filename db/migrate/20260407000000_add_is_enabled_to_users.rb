class AddIsEnabledToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_enabled, :boolean, default: true, null: false
  end
end
