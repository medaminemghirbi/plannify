class CreatePaymentReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_receipts, id: :uuid do |t|
      t.uuid :payment_id, null: false
      t.uuid :generated_by_id, null: false
      t.datetime :generated_at, null: false
      t.jsonb :details_snapshot, null: false, default: {}
      t.text :client_signature_data, null: false
      t.text :gym_signature_data, null: false

      t.timestamps
    end

    add_foreign_key :payment_receipts, :payments
    add_foreign_key :payment_receipts, :users, column: :generated_by_id
    add_index :payment_receipts, :payment_id, unique: true
  end
end