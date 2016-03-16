module InvitingUsers
  # Override render and redirect_to so that we sign the invited user out
  # before we render or redirect anywhere.
  def render(*args)
    sign_out_invited_user
    super
  end

  # This is a "just in case" - no invited user should be redirect anywhere
  def redirect_to(*args)
    sign_out_invited_user
    super
  end

  private

  def set_invite_token
    @invite_token = params[:token]
  end

  def set_invited_user
    raise NotImplementedError("You have to implement this in your controller")
  end

  def check_invited_user
    @invited_user.present?
  end

  def set_invite
    raise NotImplementedError("You have to implement this in your controller")
  end

  def check_invite
    @invite.present?
  end

  def check_user_can_contribute_to_study
    if params[:token].present?
      set_invite_token
      set_invited_user
      return forbidden unless check_invited_user
      set_invite
      return forbidden unless check_invite
      # We have to sign in the user because we rely on the current_user helper
      # in lots of places to tie up actions and outputs with users, however,
      # we sign them out again after the action has finished so that they
      # don't ever get access to things they shouldn't
      sign_in(@invited_user)
    else
      check_user_can_manage_study
    end
  end

  def sign_out_invited_user
    unless @invited_user.blank?
      sign_out(@invited_user)
    end
  end
end
