class AdminMailer < ApplicationMailer
  def new_user_waiting_for_approval(user)
    @user = user
    admins = User.where(is_admin: true).map(&:email)
    mail to: admins
  end
end
