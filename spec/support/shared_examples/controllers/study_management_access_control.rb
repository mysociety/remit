require "support/devise"

RSpec.shared_examples_for "study management action" do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let(:pi) { FactoryGirl.create(:user) }
  let(:rm) { FactoryGirl.create(:user) }
  let(:study) do
    FactoryGirl.create(:study, principal_investigator: pi,
                               research_manager: rm)
  end

  describe "access control" do
    it "requires a logged in user" do
      sign_out :user
      trigger_action study
      expect(response).to redirect_to(new_user_session_path)
    end

    it "allows admin users" do
      sign_in admin_user
      trigger_action study
      expect(response).not_to have_http_status(:forbidden)
    end

    it "allows the study pi" do
      sign_in pi
      trigger_action study
      expect(response).not_to have_http_status(:forbidden)
    end

    it "allows the study rm" do
      sign_in rm
      trigger_action study
      expect(response).not_to have_http_status(:forbidden)
    end

    it "doesn't allow other users" do
      sign_in user
      trigger_action study
      expect(response).to have_http_status(:forbidden)
    end
  end
end
