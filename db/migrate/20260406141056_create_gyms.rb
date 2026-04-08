class CreateGyms < ActiveRecord::Migration[7.1]
  def change
    create_table :gyms, id: :uuid do |t|
      t.string :name, null: false
      t.string :address
      t.references :admin, type: :uuid, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :gyms, :name
    remove_index :gyms, :admin_id
    add_index :gyms, :admin_id, unique: true
  end
end
