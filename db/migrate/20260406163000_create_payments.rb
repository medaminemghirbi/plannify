class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :client_profile, null: false, type: :uuid, foreign_key: true
      t.references :created_by, null: true, type: :uuid, foreign_key: { to_table: :users }
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.date :starts_on, null: false
      t.integer :duration_months, null: false, default: 1
      t.string :status, null: false, default: "pending"
      t.text :notes

      t.timestamps
    end

    add_index :payments, :starts_on
    add_index :payments, [:client_profile_id, :starts_on], name: "index_payments_client_starts_on"
  end
end
