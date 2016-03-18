class DeliveryUpdateInviteMailer < ApplicationMailer
  def invite(user, invites)
    @invites = invites
    @user = user
    mail to: @user.email
  end
end
