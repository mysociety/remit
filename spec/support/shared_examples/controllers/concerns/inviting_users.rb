require "support/devise"

RSpec.shared_examples_for "inviting users action" do
  context "when someone's been invited via email" do
    before do
      sign_out :user
    end

    it "allows them in via their invite_token" do
      trigger_action(study, invite_token)
      expect(response).to have_http_status(:success)
    end

    context "but they visit with the wrong invite code" do
      it "forbids access" do
        bad_token = "xxxxxxxxxx"
        trigger_action(study, bad_token)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "but they try to access another study" do
      it "forbids access" do
        other_study = FactoryGirl.create(:study)
        trigger_action(other_study, invite_token)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
