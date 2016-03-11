class MakeDeliveryUpdateTokenRequired < ActiveRecord::Migration
  def up
    User.all.each do |user|
      if user.delivery_update_token.nil?
        user.delivery_update_token = User.generate_unique_secure_token
        user.save!
      end
    end
    change_column_null :users, :delivery_update_token, false
  end

  def down
    change_column_null :users, :delivery_update_token, true
  end
end
