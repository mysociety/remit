require "rails_helper"

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    context "when there are some studies" do
      let!(:other_study_type) { FactoryGirl.create(:other_type) }
      let(:studies) { FactoryGirl.create_list(:study, 20) }

      before do
        studies.sort! { |a, b| a.updated_at <=> b.updated_at }
        studies.reverse!
      end

      it "lists the studies" do
        get :index
        expect(assigns[:studies]).to match_array(studies.first(10))
      end

      it "paginates the studies" do
        get :index, page: 2
        expect(assigns[:studies]).to match_array(studies.last(10))
      end
    end
  end
end
