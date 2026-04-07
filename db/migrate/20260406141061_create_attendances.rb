class CreateAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :attendances, id: :uuid do |t|
      t.references :client_profile, type: :uuid, null: false, foreign_key: true
      t.references :training_group, type: :uuid, null: false, foreign_key: true
      t.date :date, null: false
      t.string :status, null: false

      t.timestamps
    end

    add_index :attendances, [:client_profile_id, :training_group_id, :date], unique: true, name: "index_attendance_client_group_date"
  end
end
