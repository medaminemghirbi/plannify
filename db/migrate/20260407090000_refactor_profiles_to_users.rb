class RefactorProfilesToUsers < ActiveRecord::Migration[7.1]
  def change
    # Add gym associations to users for direct references
    add_column :users, :gym_id, :uuid
    add_foreign_key :users, :gyms

    # Create join tables for multi-gym support
    create_table :coach_gyms, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :gym_id, null: false
      t.timestamps
    end
    add_foreign_key :coach_gyms, :users, column: :user_id
    add_foreign_key :coach_gyms, :gyms
    add_index :coach_gyms, [:user_id, :gym_id], unique: true

    create_table :client_gyms, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :gym_id, null: false
      t.timestamps
    end
    add_foreign_key :client_gyms, :users, column: :user_id
    add_foreign_key :client_gyms, :gyms
    add_index :client_gyms, [:user_id, :gym_id], unique: true

    # Change training_groups to use coach_id directly
    add_column :training_groups, :coach_id, :uuid
    add_foreign_key :training_groups, :users, column: :coach_id

    # Migrate data from coach_profiles to new structure
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO coach_gyms (user_id, gym_id, created_at, updated_at)
          SELECT user_id, gym_id, created_at, updated_at FROM coach_profiles
          ON CONFLICT (user_id, gym_id) DO NOTHING;
        SQL

        execute <<-SQL
          UPDATE training_groups
          SET coach_id = cp.user_id
          FROM coach_profiles cp
          WHERE training_groups.coach_profile_id = cp.id;
        SQL

        execute <<-SQL
          INSERT INTO client_gyms (user_id, gym_id, created_at, updated_at)
          SELECT user_id, gym_id, created_at, updated_at FROM client_profiles
          ON CONFLICT (user_id, gym_id) DO NOTHING;
        SQL
      end
    end

    # Update attendances and other tables
    add_column :attendances, :client_id, :uuid
    add_foreign_key :attendances, :users, column: :client_id

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE attendances
          SET client_id = cp.user_id
          FROM client_profiles cp
          WHERE attendances.client_profile_id = cp.id;
        SQL
      end
    end

    add_column :payments, :client_id, :uuid
    add_foreign_key :payments, :users, column: :client_id

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE payments
          SET client_id = cp.user_id
          FROM client_profiles cp
          WHERE payments.client_profile_id = cp.id;
        SQL
      end
    end

    # Update group_memberships
    add_column :group_memberships, :client_id, :uuid
    add_foreign_key :group_memberships, :users, column: :client_id

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE group_memberships
          SET client_id = cp.user_id
          FROM client_profiles cp
          WHERE group_memberships.client_profile_id = cp.id;
        SQL
      end
    end
  end
end
