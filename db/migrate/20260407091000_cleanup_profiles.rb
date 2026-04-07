class CleanupProfiles < ActiveRecord::Migration[7.1]
  def change
    # Remove old foreign key columns after they're migrated
    remove_foreign_key :attendances, column: :client_profile_id, if_exists: true
    remove_column :attendances, :client_profile_id, :uuid, if_exists: true

    remove_foreign_key :payments, column: :client_profile_id, if_exists: true
    remove_column :payments, :client_profile_id, :uuid, if_exists: true

    remove_foreign_key :group_memberships, column: :client_profile_id, if_exists: true
    remove_column :group_memberships, :client_profile_id, :uuid, if_exists: true

    remove_foreign_key :training_groups, column: :coach_profile_id, if_exists: true
    remove_column :training_groups, :coach_profile_id, :uuid, if_exists: true

    remove_foreign_key :gym, column: :coach_profiles, if_exists: true
    remove_foreign_key :gym, column: :client_profiles, if_exists: true

    # Drop profile tables
    drop_table :coach_profiles, if_exists: true
    drop_table :client_profiles, if_exists: true
  end
end
