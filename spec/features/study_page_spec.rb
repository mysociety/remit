# encoding: utf-8
require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "Study page" do
  let(:study) { FactoryGirl.create(:study) }

  it "exists" do
    visit study_path(study)
    expect(page).to have_text(study.title)
  end

  context "when the user is an admin" do
    let(:admin) { FactoryGirl.create(:admin_user) }

    it "lets you edit the study in the admin" do
      sign_in_account(admin.email)
      visit study_path(study)
      click_link("Edit study details")
      expect(current_path).to eq edit_admin_study_path(study)
    end
  end

  describe "editing the study stage" do
    let(:pi) { FactoryGirl.create(:user) }
    let(:rm) { FactoryGirl.create(:user) }
    let(:admin) { FactoryGirl.create(:admin_user) }
    let(:other) { FactoryGirl.create(:user) }

    before do
      study.principal_investigator = pi
      study.research_manager = rm
      study.save!
    end

    context "when the study is in the protocol_erb stage" do
      before do
        study.study_stage = "protocol_erb"
        study.protocol_needed = true
        study.erb_status = FactoryGirl.create(:accept)
        study.save!
      end

      it "can be progressed to the delivery stage by allowed users" do
        [pi, rm, admin].each do |user|
          sign_in_account(user.email)
          visit study_path(study)
          click_link "This study is in delivery"
          expect(page).to have_text "Study stage updated successfully"
          expect(study.reload.delivery?).to be true
          # We have to reset the study for each user
          sign_out
          study.study_stage = "protocol_erb"
          study.save!
        end
      end

      it "is hidden from other users" do
        sign_in_account(other.email)
        visit study_path(study)
        expect(page).not_to have_text("This study is in delivery")
      end

      it "is hidden from anonymous users" do
        visit study_path(study)
        expect(page).not_to have_text("This study is in delivery")
      end
    end

    context "when the study is in the delivery stage" do
      before do
        study.study_stage = "delivery"
        study.protocol_needed = true
        study.erb_status = FactoryGirl.create(:accept)
        study.save!
      end

      it "can be progressed to the completion stage by allowed users" do
        [pi, rm, admin].each do |user|
          sign_in_account(user.email)
          visit study_path(study)
          click_link "This study has completed"
          expect(page).to have_text "Study stage updated successfully"
          expect(study.reload.completion?).to be true
          # We have to reset the study for each user
          sign_out
          study.study_stage = "delivery"
          study.save!
        end
      end

      it "is hidden from other users" do
        sign_in_account(other.email)
        visit study_path(study)
        expect(page).not_to have_text("This study has completed")
      end

      it "is hidden from anonymous users" do
        visit study_path(study)
        expect(page).not_to have_text("This study has completed")
      end
    end
  end
end
