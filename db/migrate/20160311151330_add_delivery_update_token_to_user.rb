class AddDeliveryUpdateTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :delivery_update_token, :string
    add_index :users, :delivery_update_token, unique: true
  end
end
