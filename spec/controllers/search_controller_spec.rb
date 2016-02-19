require "rails_helper"
require "support/study_listing_controller_shared_examples"

RSpec.describe SearchController, type: :controller do
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

    context "searching by various fields" do
      before do
        topic = StudyTopic.find_by_name("Brucellosis") ||
                FactoryGirl.create(:brucellosis)
        pi = FactoryGirl.create(:user, name: "Barry Einstein")
        @study = FactoryGirl.create(:study,
                  country_codes: ['ZW'],
                  title: "water sanitation study",
                  study_topics: [topic],
                  principal_investigator: pi
                )
      end

      it "allows searching by title" do
        get :index, { q: "sanitation" }
        expect(assigns[:studies]).to include @study
      end

      it "allows searching by PI name" do
        get :index, { q: "einstein" }
        expect(assigns[:studies]).to include @study
      end

      it "allows searching by topic" do
        get :index, { q: "brucellosis" }
        expect(assigns[:studies]).to include @study
      end

      it "allows searching by country" do
        get :index, { q: "zimbabwe" }
        expect(assigns[:studies]).to include @study
      end
    end
  end
end
