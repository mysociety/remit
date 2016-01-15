require "rails_helper"

RSpec.describe "User accounts" do
  # Helper method to sign up for a new account
  def sign_up_for_an_account(email, name)
    visit "/"
    click_link "Sign In or Sign Up"
    click_link "Sign up"
    fill_in "Email", with: email
    fill_in "Name", with: name
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"
  end

  describe "Signing up" do
    it "Lets you sign up for an account" do
      sign_up_for_an_account "test@example.com", "Test User"
      confirmation_mail = ActionMailer::Base.deliveries.last
      expect(confirmation_mail.to[0]).to eq "test@example.com"
      user_account = User.find_by_email("test@example.com")
      expect(user_account).not_to be_nil
      expect(user_account.confirmed?).to be false
      expect(user_account.name).to eq "Test User"
    end

    it "Lets you confirm your account" do
      sign_up_for_an_account "test@example.com", "Test User"
      email = ActionMailer::Base.deliveries.last
      token = email.body.match(/confirmation_token=\w*/)
      visit "/users/confirmation?#{token}"
      expected_text = "Your email address has been successfully confirmed"
      expect(page).to have_text(expected_text)

      user_account = User.find_by_email("test@example.com")
      expect(user_account).not_to be_nil
      expect(user_account.confirmed?).to be true
    end

    it "Lets you resend a confirmation email" do
      # Clear the list of mails so we can be sure only this spec creates
      # them
      ActionMailer::Base.deliveries = []
      sign_up_for_an_account "test@example.com", "Test User"
      expect(ActionMailer::Base.deliveries.length).to eq 1
      visit "/"
      click_link "Sign In or Sign Up"
      click_link "Didn't receive confirmation instructions?"
      fill_in "Email", with: "test@example.com"
      click_button "Resend confirmation instructions"
      expect(ActionMailer::Base.deliveries.length).to eq 2
      expect(ActionMailer::Base.deliveries[0].to[0]).to eq "test@example.com"
      expect(ActionMailer::Base.deliveries[1].to[0]).to eq "test@example.com"
    end
  end

  describe "Signing in" do
    it "Lets you sign in"
    it "Redirects admin users to the dashboard"
    it "Lets you reset your password if you've forgotten it"
  end

  describe "Changing account details" do
    it "Lets you change your password"
    it "Lets you change your email address"
    it "Lets you change your name"
    it "Lets you delete your account"
  end

  describe "Signing out" do
    it "Lets you sign out"
  end
end
