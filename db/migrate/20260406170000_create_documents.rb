class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents, id: :uuid do |t|
      t.references :gym, null: false, type: :uuid, foreign_key: true
      t.references :created_by, null: true, type: :uuid, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :kind, null: false, default: "other"
      t.text :description

      t.timestamps
    end

    add_index :documents, :kind
    add_index :documents, :title
  end
end
