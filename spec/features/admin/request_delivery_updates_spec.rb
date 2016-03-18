require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "RequestDeliveryUpdates" do
  let!(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user1) { FactoryGirl.create(:user) }
  let!(:user2) { FactoryGirl.create(:user) }
  let!(:user3) { FactoryGirl.create(:user) }
  let!(:study1) do
    FactoryGirl.create(:study, principal_investigator: user1,
                               study_stage: :delivery,
                               protocol_needed: false)
  end
  let!(:study2) do
    FactoryGirl.create(:study, principal_investigator: user1,
                               study_stage: :delivery,
                               protocol_needed: false)
  end
  let!(:study3) { FactoryGirl.create(:study, principal_investigator: user1) }
  let!(:study4) do
    FactoryGirl.create(:study, principal_investigator: user2,
                               study_stage: :delivery,
                               protocol_needed: false)
  end
  let!(:study5) { FactoryGirl.create(:study, principal_investigator: user3) }

  before do
    # Clear out emails for new users etc before our tests
    ActionMailer::Base.deliveries = []
  end

  it "allows you to create a new delivery update" do
    sign_in_account(admin_user.email)
    within "#title_bar" do
      click_link "Request delivery updates"
    end

    expect(page).to have_text("#{user1.name} (#{user1.email}) - 2 studies")
    expect(page).to have_text("#{user2.name} (#{user2.email}) - 1 study")
    expect(page).not_to have_text("#{user3.name} (#{user3.email}) - 1 study")

    click_link "Send 2 delivery update requests"

    expect(page).to have_text("Requests sent!")

    expect(ActionMailer::Base.deliveries.count).to eq 2

    first_mail = ActionMailer::Base.deliveries.first
    second_mail = ActionMailer::Base.deliveries.second

    expect(first_mail.to).to eq [user1.email]
    expect(second_mail.to).to eq [user2.email]

    expect(first_mail.body.to_s).to(
      have_text(new_study_delivery_update_url(study1)))
    expect(first_mail.body.to_s).to(
      have_text(new_study_delivery_update_url(study2)))
    expect(second_mail.body.to_s).to(
      have_text(new_study_delivery_update_url(study4)))
  end
end
