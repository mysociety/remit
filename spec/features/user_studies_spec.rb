require "rails_helper"
require "support/user_account_feature_helper"

RSpec.describe "User studies page" do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user_studies) do
    FactoryGirl.create_list(:study, 20, principal_investigator: user)
  end
  let!(:other_user_studies) do
    FactoryGirl.create_list(:study, 20, principal_investigator: other_user)
  end

  it "lists the user's studies" do
    sign_in_account(user.email)
    visit user_studies_path(user)
    user_studies.last(10).each do |study|
      expect(page).to have_link(study.title, href: study_path(study))
    end
  end

  it "returns a forbidden page when you try to access another user's page" do
    sign_in_account(user.email)
    visit user_studies_path(other_user)
    expect(page).to have_text "You are not allowed to access the page"
  end

  it "lets an admin access any user's page" do
    sign_in_account(admin_user.email)

    visit user_studies_path(user)
    user_studies.last(10).each do |study|
      expect(page).to have_link(study.title, href: study_path(study))
    end

    visit user_studies_path(other_user)
    other_user_studies.last(10).each do |study|
      expect(page).to have_link(study.title, href: study_path(study))
    end
  end
end
