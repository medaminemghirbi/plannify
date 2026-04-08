class AddCoordinatesToGyms < ActiveRecord::Migration[7.1]
  def change
    add_column :gyms, :latitude, :decimal, precision: 10, scale: 6
    add_column :gyms, :longitude, :decimal, precision: 10, scale: 6
  end
end
