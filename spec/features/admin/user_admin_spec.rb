require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "UserAdmin" do
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
    click_button "Create User"
    expect(page).to have_text "User was successfully created"
    user = User.find_by_name("A New User")
    expect(user).not_to be nil
    # Admin auto-confirms new users
    expect(user.confirmed?).to be true
  end

  context "with an existing user" do
    let!(:user) { FactoryGirl.create(:normal_user) }

    before do
      # An easy way to refresh the page
      click_link "Users"
    end

    it "allows you to edit the user" do
      click_link "Edit", href: edit_admin_user_path(user)
      check "Is admin"
      click_button "Update User"
      expect(page).to have_text "User was successfully updated"
      expect(user.reload.is_admin).to be true
    end

    it "allows you to delete the user" do
      click_link "Delete", href: admin_user_path(user)
      expect(page).to have_text "User was successfully destroyed"
      expect(User.find_by_name("A New User")).to be nil
    end

    it "allows you to approve the user" do
      user.approved = false
      click_link "Edit", href: edit_admin_user_path(user)
      check "Approved"
      click_button "Update User"
      expect(page).to have_text "User was successfully updated"
      expect(user.reload.approved).to be true
    end
  end
end
