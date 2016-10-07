class DeliveryUpdateInviteMailer < ApplicationMailer
  def invite(user, invites)
    @invites = invites
    @user = user
    # mail to: @user.email
    mail to: "kim.west@london.msf.org"
  end
end
