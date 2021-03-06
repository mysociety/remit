require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "User accounts" do
  describe "Signing up" do
    context "when you have an MSF email address" do
      it "Lets you sign up for an account" do
        sign_up_for_an_account "test@msf.org", "Test User"
        confirmation_mail = ActionMailer::Base.deliveries.last

        expect(confirmation_mail.to[0]).to eq "test@msf.org"
        user_account = User.find_by_email("test@msf.org")
        expect(user_account).not_to be_nil
        expect(user_account.confirmed?).to be false
        expect(user_account.approved?).to be true
        expect(user_account.name).to eq "Test User"
      end

      it "Lets you confirm your account" do
        sign_up_for_an_account "test@msf.org", "Test User"
        email = ActionMailer::Base.deliveries.last
        token = email.body.match(/confirmation_token=[\w-]*/)
        visit "/users/confirmation?#{token}"
        expected_text = "Your email address has been successfully confirmed"
        expect(page).to have_text(expected_text)

        user_account = User.find_by_email("test@msf.org")
        expect(user_account).not_to be_nil
        expect(user_account.confirmed?).to be true
        expect(user_account.approved?).to be true
      end

      it "Lets you resend a confirmation email" do
        sign_up_for_an_account "test@msf.org", "Test User"

        first_email = ActionMailer::Base.deliveries.last

        visit "/"
        click_link "Sign In or Sign Up"
        click_link "Didn't receive confirmation instructions?"
        fill_in "Email", with: "test@msf.org"
        click_button "Resend confirmation instructions"

        second_email = ActionMailer::Base.deliveries.last

        expect(first_email.body.match(/confirmation_token=[\w-]*/)).not_to(
          be nil)
        expect(second_email.body.match(/confirmation_token=[\w-]*/)).not_to(
          be nil)
      end
    end

    context "when you have a non-MSF email address" do
      let!(:admin) { FactoryGirl.create(:admin_user) }

      before do
        ActionMailer::Base.deliveries = []
      end

      it "Lets you sign up for an account" do
        sign_up_for_an_account "test@example.com", "Test User"
        confirmation_mail = ActionMailer::Base.deliveries.first
        admin_mail = ActionMailer::Base.deliveries.last

        expect(confirmation_mail.to[0]).to eq "test@example.com"
        expect(admin_mail.to[0]).to eq admin.email
        user_account = User.find_by_email("test@example.com")
        expect(user_account).not_to be_nil
        expect(user_account.confirmed?).to be false
        expect(user_account.approved?).to be false
        expect(user_account.name).to eq "Test User"
      end

      it "Lets you confirm your account" do
        sign_up_for_an_account "test@example.com", "Test User"
        email = ActionMailer::Base.deliveries.first
        token = email.body.match(/confirmation_token=[\w-]*/)
        visit "/users/confirmation?#{token}"
        expected_text = "Your email address has been successfully confirmed"
        expect(page).to have_text(expected_text)

        user_account = User.find_by_email("test@example.com")
        expect(user_account).not_to be_nil
        expect(user_account.confirmed?).to be true
        expect(user_account.approved?).to be false
      end

      it "Lets you resend a confirmation email" do
        sign_up_for_an_account "test@example.com", "Test User"

        first_email = ActionMailer::Base.deliveries.first

        visit "/"
        click_link "Sign In or Sign Up"
        click_link "Didn't receive confirmation instructions?"
        fill_in "Email", with: "test@example.com"
        click_button "Resend confirmation instructions"

        second_email = ActionMailer::Base.deliveries.last

        expect(first_email.body.match(/confirmation_token=[\w-]*/)).not_to(
          be nil)
        expect(second_email.body.match(/confirmation_token=[\w-]*/)).not_to(
          be nil)
      end
    end
  end

  describe "Signing in" do
    let(:user) { FactoryGirl.create(:confirmed_user) }
    let(:admin_user) { FactoryGirl.create(:admin_user) }

    context "when your account is approved" do
      it "Lets you sign in" do
        sign_in_account(user.email, "password")
        expect(page).to have_text("Signed in successfully")
      end

      it "Redirects users to the homepage if they have no studies" do
        visit destroy_user_session_path
        sign_in_account(user.email)
        expect(current_path).to eq root_path
      end

      it "Redirects users to their study page if they have any studies" do
        FactoryGirl.create(:study, principal_investigator: user)
        visit destroy_user_session_path
        sign_in_account(user.email)
        expect(current_path).to eq user_studies_path(user)
      end

      it "Redirects admin users to the dashboard" do
        visit destroy_user_session_path
        sign_in_account(admin_user.email)
        expect(current_path).to eq admin_dashboard_path
      end

      it "Lets you reset your password if you've forgotten it" do
        visit "/"
        click_link "Sign In or Sign Up"
        click_link "Forgot your password?"
        fill_in "Email", with: user.email
        click_button "Send me a reset link"

        expected_text = "You will receive an email with instructions on how " \
                        "to reset your password in a few minutes"
        expect(page).to have_text expected_text
        email = ActionMailer::Base.deliveries.last
        expect(email.to[0]).to eq user.email
        token = email.body.match(/reset_password_token=[\w-]*/)

        visit "/users/password/edit?#{token}"
        fill_in "New password", with: "password"
        fill_in "Confirm new password", with: "password"
        click_button "Change my password"

        expected_text = "Your password has been changed successfully. You " \
                        "are now signed in"
        expect(page).to have_text(expected_text)
      end
    end

    context "when your account is not approved" do
      it "doesn't let you sign in" do
        user.approved = false
        user.save!
        sign_in_account(user.email, "password")
        expected_text = "Your email address has been confirmed, but your " \
                        "account still has to be approved by the " \
                        "administrator before you can access the site."
        expect(page).to have_text(expected_text)
      end
    end
  end

  describe "Changing account details" do
    let(:user) { FactoryGirl.create(:confirmed_user) }

    before(:each) do
      sign_in_account(user.email)
      click_link "Change your password"
    end

    it "Lets you change your password" do
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "password123"
      fill_in "Current password", with: "password"
      click_button "Update"

      expect(page).to have_text("Your account has been updated successfully")
    end

    it "Lets you change your email address" do
      fill_in "Email", with: "test2@example.com"
      fill_in "Current password", with: "password"
      click_button "Update"

      expected_text = "You updated your account successfully, but we need " \
                      "to verify your new email address. Please check your " \
                      "email and follow the confirm link to confirm your " \
                      "new email address"
      expect(page).to have_text expected_text

      email = ActionMailer::Base.deliveries.last
      expect(email.to[0]).to eq "test2@example.com"
      token = email.body.match(/confirmation_token=[\w-]*/)

      visit "/users/confirmation?#{token}"

      expected_text = "Your email address has been successfully confirmed"
      expect(page).to have_text(expected_text)
      expect(user.reload.email).to eq("test2@example.com")
    end

    it "Lets you change your name" do
      fill_in "Name", with: "A New Name"
      fill_in "Current password", with: "password"
      click_button "Update"
      expect(page).to have_text("Your account has been updated successfully")
      expect(user.reload.name).to eq "A New Name"
    end

    it "Lets you delete your account" do
      click_button "Cancel my account"
      expected_text = "Bye! Your account has been successfully cancelled. " \
                      "We hope to see you again soon"
      expect(page).to have_text expected_text
      expect(User.find_by_email(user.email)).to be_nil
    end
  end

  describe "Signing out" do
    let(:user) { FactoryGirl.create(:confirmed_user) }

    it "Lets you sign out" do
      sign_in_account(user.email)
      click_link "Sign Out"
      expect(page).to have_text("Signed out successfully")
    end
  end
end
