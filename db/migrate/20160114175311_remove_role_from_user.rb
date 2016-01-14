class RemoveRoleFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :role, :role

    execute <<-SQL
      DROP TYPE role;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
