class CreateTrainingGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :training_groups, id: :uuid do |t|
      t.string :name, null: false
      t.references :gym, type: :uuid, null: false, foreign_key: true
      t.references :coach_profile, type: :uuid, foreign_key: true
      t.integer :capacity

      t.timestamps
    end

    add_index :training_groups, [:gym_id, :name], unique: true
  end
end
