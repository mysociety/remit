class AddApprovedToUser < ActiveRecord::Migration
  def change
    add_column :users, :approved, :boolean, default: false,
                                            null: false,
                                            index: true
  end
end
