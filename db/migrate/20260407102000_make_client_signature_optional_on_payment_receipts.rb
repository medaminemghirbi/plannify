class MakeClientSignatureOptionalOnPaymentReceipts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :payment_receipts, :client_signature_data, true
  end
end