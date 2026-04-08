class EnforceOneGymPerAdmin < ActiveRecord::Migration[7.1]
  def up
    return if index_exists?(:gyms, :admin_id, unique: true)

    execute <<~SQL
      DELETE FROM gyms a
      USING gyms b
      WHERE a.admin_id = b.admin_id
      AND a.id < b.id;
    SQL

    add_index :gyms, :admin_id, unique: true
  end

  def down
    remove_index :gyms, :admin_id if index_exists?(:gyms, :admin_id)
  end
end