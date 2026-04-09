class DropLegacyUserGymJoinTables < ActiveRecord::Migration[7.1]
  def up
    drop_table :coach_gyms, if_exists: true
    drop_table :client_gyms, if_exists: true
  end

  def down
    create_table :coach_gyms, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :gym_id, null: false
      t.timestamps
    end
    add_foreign_key :coach_gyms, :users, column: :user_id
    add_foreign_key :coach_gyms, :gyms
    add_index :coach_gyms, [:user_id, :gym_id], unique: true

    create_table :client_gyms, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :gym_id, null: false
      t.timestamps
    end
    add_foreign_key :client_gyms, :users, column: :user_id
    add_foreign_key :client_gyms, :gyms
    add_index :client_gyms, [:user_id, :gym_id], unique: true
  end
end
