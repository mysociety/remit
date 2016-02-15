class AlertMailer < ApplicationMailer
  def delayed_completing(study, user)
    @study = study
    @user = user
    mail to: user.email
  end

  def approval_expiring(study, user)
    @study = study
    @user = user
    mail to: user.email
  end

  def response_overdue(study, user)
    @study = study
    @user = user
    mail to: user.email
  end
end
