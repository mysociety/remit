require "rails_helper"

RSpec.describe DeliveryUpdateInviteMailer, type: :mailer do
  describe "invite" do
    let(:user) do
      FactoryGirl.create(:user, name: "Test User",
                                delivery_update_token: "TOKEN")
    end
    let(:study1) do
      FactoryGirl.create(:study, principal_investigator: user,
                                 reference_number: "STUDY1",
                                 title: "Study 1 Title",
                                 id: 1)
    end
    let(:study2) do
      FactoryGirl.create(:study, principal_investigator: user,
                                 reference_number: "STUDY2",
                                 title: "Study 2 Title",
                                 id: 2)
    end
    let(:study3) do
      FactoryGirl.create(:study, principal_investigator: user,
                                 reference_number: "STUDY3",
                                 title: "Study 3 Title",
                                 id: 3)
    end
    let!(:invite1) do
      FactoryGirl.create(:delivery_update_invite, study: study1,
                                                  invited_user: user)
    end
    let!(:invite2) do
      FactoryGirl.create(:delivery_update_invite, study: study2,
                                                  invited_user: user)
    end
    let!(:invite3) do
      FactoryGirl.create(:delivery_update_invite, study: study3,
                                                  invited_user: user)
    end
    let(:invites) { [invite1, invite2, invite3] }
    let(:mail) { DeliveryUpdateInviteMailer.invite(user, invites) }

    before do
      # Mock the current time, so that we can have a fixed deadline in our
      # email specs
      travel_to Time.zone.local(2016, 8, 15, 0, 0, 0) - 4.weeks
    end

    after do
      travel_back
    end

    it "renders the headers" do
      expect(mail.subject).to eq("It's time to update MSF-OCA's Research " \
                                 "Management and Impact Tool (ReMIT) on " \
                                 "the progress of your research studies")
      expect(mail.to).to eq([user.email])
    end

    it "renders the body" do
      fixture = Rails.root.join("spec",
                                "fixtures",
                                "delivery_update_invite_mailer",
                                "invite.txt")
      expect(IO.readlines(fixture).join).to eq mail.body.to_s
    end
  end
end
