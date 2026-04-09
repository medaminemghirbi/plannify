class AddTypeToUsers < ActiveRecord::Migration[7.1]
  def up
    # no-op: this project now uses a role column instead of STI.
  end

  def down
    # no-op
  end
end
