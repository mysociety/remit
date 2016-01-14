class AddIsAdminToUser < ActiveRecord::Migration
  def up
    add_column :users, :is_admin, :boolean, null: false, default: false

    User.find_each do |user|
      user.is_admin = user.role == "admin"
      user.save!
    end
  end

  def down
    remove_column :users, :is_admin
  end
end
