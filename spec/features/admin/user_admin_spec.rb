require "rails_helper"
require "support/user_account_feature_helper"

RSpec.describe "UserAdmin" do
  # We need these two stages just for the admin dashboard to work
  let!(:completion_stage) { FactoryGirl.create(:completion_stage) }
  let!(:withdrawn_stage) { FactoryGirl.create(:withdrawn_postponed_stage) }
  let(:admin_user) { FactoryGirl.create(:admin_user) }

  before do
    sign_in_account(admin_user.email)
    click_link "Users"
  end

  it "allows you to create a new user" do
    click_link "New User"
    fill_in "Name", with: "A New User"
    fill_in "Email", with: "new-user@example.com"
    within "#user_password_input" do
      fill_in "Password", with: "password"
    end
    fill_in "Password confirmation", with: "password"
    select "normal_user", from: "Role"
    click_button "Create User"
    expect(page).to have_text "User was successfully created"
    user = User.find_by_name("A New User")
    expect(user).not_to be nil
    expect(user.confirmed?).to be false
  end

  context "with an existing user" do
    let!(:user) { FactoryGirl.create(:normal_user) }

    before do
      # An easy way to refresh the page
      click_link "Users"
    end

    it "allows you to edit the user" do
      click_link "Edit", href: edit_admin_user_path(user)
      select "admin", from: "Role"
      click_button "Update User"
      expect(page).to have_text "User was successfully updated"
      expect(user.reload.role).to eq "admin"
    end

    it "allows you to delete the user" do
      click_link "Delete", href: admin_user_path(user)
      expect(page).to have_text "User was successfully destroyed"
      expect(User.find_by_name("A New User")).to be nil
    end
  end
end
