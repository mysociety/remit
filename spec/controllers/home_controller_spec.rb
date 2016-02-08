require "rails_helper"
require "support/study_listing_controller_shared_examples"

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
  end
end
