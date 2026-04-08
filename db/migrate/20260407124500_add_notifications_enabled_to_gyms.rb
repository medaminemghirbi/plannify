class AddNotificationsEnabledToGyms < ActiveRecord::Migration[7.1]
  def change
    add_column :gyms, :notifications_enabled, :boolean, null: false, default: true
  end
end
