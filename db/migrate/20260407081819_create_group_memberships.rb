class CreateGroupMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :group_memberships, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :client_profile_id, null: false
      t.uuid :training_group_id, null: false
      t.datetime :joined_at

      t.timestamps
    end

    add_foreign_key :group_memberships, :client_profiles
    add_foreign_key :group_memberships, :training_groups
    add_index :group_memberships, [:client_profile_id, :training_group_id], unique: true
  end
end
