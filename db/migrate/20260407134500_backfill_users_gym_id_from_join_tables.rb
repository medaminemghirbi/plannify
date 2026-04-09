class BackfillUsersGymIdFromJoinTables < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      UPDATE users u
      SET gym_id = cg.gym_id
      FROM (
        SELECT DISTINCT ON (user_id) user_id, gym_id
        FROM coach_gyms
        ORDER BY user_id, created_at DESC
      ) cg
      WHERE u.id = cg.user_id
        AND u.role = 'coach'
        AND u.gym_id IS NULL;
    SQL

    execute <<~SQL
      UPDATE users u
      SET gym_id = clg.gym_id
      FROM (
        SELECT DISTINCT ON (user_id) user_id, gym_id
        FROM client_gyms
        ORDER BY user_id, created_at DESC
      ) clg
      WHERE u.id = clg.user_id
        AND u.role = 'client'
        AND u.gym_id IS NULL;
    SQL

    add_index :users, :gym_id unless index_exists?(:users, :gym_id)
  end

  def down
    remove_index :users, :gym_id if index_exists?(:users, :gym_id)
  end
end
