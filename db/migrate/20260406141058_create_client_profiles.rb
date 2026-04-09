class CreateClientProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :client_profiles, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      t.references :gym, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
