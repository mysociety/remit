require "rails_helper"

RSpec.describe DeliveryUpdateInviteMailer, type: :mailer do
  describe "invite" do
    let(:user) { FactoryGirl.create(:user, name: "Test User") }
    let(:study1) do
      FactoryGirl.create(:study, principal_investigator: user,
                                 reference_number: "STUDY1",
                                 id: 1)
    end
    let(:study2) do
      FactoryGirl.create(:study, principal_investigator: user,
                                 reference_number: "STUDY2",
                                 id: 2)
    end
    let(:study3) do
      FactoryGirl.create(:study, principal_investigator: user,
                                 reference_number: "STUDY3",
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

    it "renders the headers" do
      expect(mail.subject).to eq("It's time to submit your delivery " \
                                 "indicator reports on ReMIT")
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
