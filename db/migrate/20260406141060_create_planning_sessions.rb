class CreatePlanningSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :planning_sessions, id: :uuid do |t|
      t.references :training_group, type: :uuid, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :recurrence

      t.timestamps
    end

    add_index :planning_sessions, :start_time
  end
end
