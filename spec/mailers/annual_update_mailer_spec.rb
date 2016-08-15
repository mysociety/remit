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

    before do
      # Mock the current time, so that we can have a fixed deadline in our
      # email specs
      travel_to Time.zone.local(2016, 8, 15, 0, 0, 0) - 4.weeks
    end

    after do
      travel_back
    end

    it "sends to the users email address" do
      expect(mail.to.first).to eq user.email
    end

    it "sets the subject" do
      expect(mail.subject).to eq("It's time to update MSF-OCA's Research " \
                                 "Management and Impact Tool (ReMIT) on " \
                                 "the impact of your research")
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
