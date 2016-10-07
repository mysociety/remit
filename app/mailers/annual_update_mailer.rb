class AnnualUpdateMailer < ApplicationMailer
  def invite(user, invites)
    @studies = user.principal_investigator_studies.active
    @invites = invites
    @user = user
    # mail to: @user.email
    mail to: "kim.west@london.msf.org"
  end
end
