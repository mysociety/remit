require "securerandom"

class StudyInvitesController < ApplicationController
  before_action :set_study_from_study_id
  before_action :check_user_can_manage_study
  before_action :set_inviting_user

  def create
    invited_email = study_invite_params[:invited_email]
    @invited_user = find_or_create_invited_user(invited_email)
    @study_invite = StudyInvite.new(study: @study,
                                    inviting_user: @inviting_user,
                                    invited_user: @invited_user)
    begin
      unless @study_invite.save
        flash.now[:alert] = "Sorry, looks like we're missing something, can " \
                            "you double check?"
        return render "studies/show"
      end
    rescue
      flash.now[:alert] = "Sorry, something went wrong sending your " \
                          "invite. Can you try again?"
      return render "studies/show"
    end
    redirect_to @study, success: "#{@invited_user.email} was invited " \
                                "successfully. They'll receive an email " \
                                "with instructions on how to contribute."
  end

  private

  def set_inviting_user
    @inviting_user = current_user
  end

  def find_or_create_invited_user(email)
    return if email.blank?
    user = User.find_by_email(email)
    if user.blank?
      password = SecureRandom.base64(31)
      external_location = MsfLocation.external_location
      user = User.new(email: email,
                      name: email,
                      password: password,
                      password_confirmation: password,
                      msf_location: external_location,
                      external_location: "Invited external user",
                      approved: true)
      user.skip_confirmation!
      user.save!
    end
    user
  end

  def study_invite_params
    params.require(:study_invite).permit(:invited_email)
  end
end
