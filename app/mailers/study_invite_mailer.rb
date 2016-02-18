class StudyInviteMailer < ApplicationMailer
  def invite(invite)
    @invite = invite
    @study = invite.study
    @inviting_user = invite.inviting_user
    @invited_user = invite.invited_user
    mail to: @invited_user.email
  end
end
