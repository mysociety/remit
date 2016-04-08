# encoding: utf-8
require "rails_helper"

RSpec.describe AnnualUpdateMailer, type: :mailer do
  describe "#invite" do
    let(:user) do
      FactoryGirl.create(:user, name: "Test User",
                                email: "iw@example.com",
                                id: 999,
                                invite_token: "invite-token")
    end
    let(:active_study1) do
      FactoryGirl.create(:study, study_stage: "delivery",
                                 protocol_needed: false,
                                 reference_number: "ABC123",
                                 id: 1)
    end
    let(:active_study2) do
      FactoryGirl.create(:study, study_stage: "delivery",
                                 protocol_needed: false,
                                 reference_number: "ABC124",
                                 id: 2)
    end
    let(:inactive_study) do
      FactoryGirl.create(:study, study_stage: "concept")
    end
    let(:invite1) do
      FactoryGirl.create(:study_invite, study: active_study1,
                                        invited_user: user)
    end
    let(:invite2) do
      FactoryGirl.create(:study_invite, study: active_study2,
                                        invited_user: user)
    end
    let(:invites) { [invite1, invite2] }

    let(:mail) { AnnualUpdateMailer.invite(user, invites) }

    it "sends to the users email address" do
      expect(mail.to.first).to eq user.email
    end

    it "sets the subject" do
      expected_subject = "It's time to submit your annual updates on ReMIT"
      expect(mail.subject).to eq expected_subject
    end

    it "has the right body" do
      fixture = Rails.root.join("spec",
                                "fixtures",
                                "annual_update_mailer",
                                "invite.txt")
      expect(IO.readlines(fixture).join).to eq mail.body.to_s
    end
  end
end
