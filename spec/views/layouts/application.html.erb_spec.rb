require "rails_helper"
require "support/devise.rb"

RSpec.describe "layouts/application.html.erb", type: :view do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let(:normal_user) { FactoryGirl.create(:user) }

  context "signed in user" do
    before do
      sign_in normal_user
      render
    end

    it "shows a sign out link" do
      expect(rendered).to have_link(
        "Sign Out",
        href: destroy_user_session_path
      )
    end

    it "shows a change password link" do
      expect(rendered).to have_link(
        "Change your password",
        href: edit_user_registration_path
      )
    end

    it "doesn't show an admin dashboard link to normal users" do
      expect(rendered).not_to have_link(
        "Admin panel",
        href: admin_dashboard_path
      )
    end

    it "shows an admin dashboard link to admin users" do
      sign_out :user
      sign_in admin_user
      render
      expect(rendered).to have_link(
        "Admin panel",
        href: admin_dashboard_path
      )
    end
  end

  context "anonymous user" do
    it "shows a sign in or sign up link" do
      sign_out :user
      render
      expect(rendered).to have_link(
        "Sign In or Sign Up",
        href: new_user_session_path
      )
    end
  end
end
