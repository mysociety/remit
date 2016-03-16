require "rails_helper"
require "support/shared_examples/controllers/concerns/listing_studies"
require "support/devise"

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    context "when there are some studies" do
      let!(:studies) { FactoryGirl.create_list(:study, 20) }
      let(:action) { :index }
      let(:params) { {} }

      it_behaves_like "study listing controller"
    end

    context "when a user is logged in" do
      it "sets flagged_studies_count" do
        user = FactoryGirl.create(:user)
        FactoryGirl.create(
          :study,
          study_stage: :delivery,
          protocol_needed: false,
          expected_completion_date: Time.zone.today - 1.day,
          completed: nil,
          principal_investigator: user)
        sign_in user
        get :index
        expect(assigns[:flagged_studies_count]).to eq 1
      end
    end

    it_behaves_like "hidden study listing controller"
  end
end
