require "rails_helper"

RSpec.describe ApprovalMailer, type: :mailer do
  describe "new_user_waiting_for_approval" do
    let!(:admin1) { FactoryGirl.create(:admin_user) }
    let!(:admin2) { FactoryGirl.create(:admin_user) }
    let(:user) do
      FactoryGirl.build(:user, approved: false,
                               name: "Test User",
                               email: "non-approved-user@example.com",
                               id: 3)
    end
    let(:mail) { ApprovalMailer.new_user_waiting_for_approval(user) }
    let(:fixture) do
      Rails.root.join("spec",
                      "fixtures",
                      "approval_mailer",
                      "new_user_waiting_for_approval.txt")
    end

    it "renders the subject" do
      expect(mail.subject).to eq "New user waiting for approval on ReMIT: " \
                                 "non-approved-user@example.com"
    end

    it "sends to all the admins" do
      expect(mail.to).to match_array [admin1.email, admin2.email]
    end

    it "has the right body" do
      expect(IO.readlines(fixture).join).to eq mail.body.to_s
    end
  end

  describe "notify_user_of_approval" do
    let(:user) do
      FactoryGirl.build(:user, approved: true,
                               name: "Test User")
    end
    let(:mail) { ApprovalMailer.notify_user_of_approval(user) }
    let(:fixture) do
      Rails.root.join("spec",
                      "fixtures",
                      "approval_mailer",
                      "notify_user_of_approval.txt")
    end

    it "renders the subject" do
      expect(mail.subject).to eq "Your account on ReMIT has been approved!"
    end

    it "sends to all the admins" do
      expect(mail.to).to match_array [user.email]
    end

    it "has the right body" do
      expect(IO.readlines(fixture).join).to eq mail.body.to_s
    end
  end
end
