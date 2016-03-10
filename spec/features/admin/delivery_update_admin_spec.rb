require "rails_helper"
require "support/user_account_feature_helper"

RSpec.describe "DeliveryUpdateAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:study) { FactoryGirl.create(:study) }
  let!(:status) { FactoryGirl.create(:delivery_update_status) }

  before do
    sign_in_account(admin_user.email)
    click_link "Delivery Updates"
  end

  it "allows you to create a new delivery update" do
    click_link "New Delivery Update"
    fill_in "Comments", with: "A test delivery update"
    select status.name, from: "Data analysis status"
    select status.name, from: "Data collection status"
    select status.name, from: "Interpretation and write up status"
    select study.title, from: "Study"
    select user.name, from: "User"
    click_button "Create Delivery update"
    expect(page).to have_text "Delivery update was successfully created"
    update = DeliveryUpdate.find_by_comments("A test delivery update")
    expect(update).not_to be nil
    expect(update.study).to eq study
    expect(update.user).to eq user
    expect(update.data_analysis_status).to eq status
    expect(update.data_collection_status).to eq status
    expect(update.interpretation_and_write_up_status).to eq status
  end

  context "with an existing delivery update" do
    let!(:update) do
      FactoryGirl.create :delivery_update,
                         study: study,
                         user: user
    end

    before do
      # An easy way to refresh the page
      click_link "Delivery Updates"
    end

    it "allows you to edit the delivery update" do
      click_link "Edit", href: edit_admin_delivery_update_path(update)
      fill_in "Comments", with: "A test delivery update updated"
      click_button "Update Delivery update"
      expect(page).to have_text "Delivery update was successfully updated"
      expect(update.reload.comments).to eq "A test delivery update updated"
    end

    it "allows you to delete the delivery update" do
      comments = update.comments
      click_link "Delete", href: admin_delivery_update_path(update)
      expect(page).to have_text "Delivery update was successfully destroyed"
      expect(DeliveryUpdate.find_by_comments(comments)).to be nil
    end
  end
end
