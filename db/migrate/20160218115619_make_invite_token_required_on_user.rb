class MakeInviteTokenRequiredOnUser < ActiveRecord::Migration
  def up
    User.all.each do |user|
      if user.invite_token.nil?
        user.invite_token = User.generate_unique_secure_token
        user.save!
      end
    end
    change_column_null :users, :invite_token, false
  end

  def down
    change_column_null :users, :invite_token, true
  end
end
