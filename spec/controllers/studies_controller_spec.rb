require "rails_helper"

RSpec.describe StudiesController, type: :controller do
  describe "GET #show" do
    let!(:other_study_type) { FactoryGirl.create(:other_type) }
    let(:study) { FactoryGirl.create(:study) }

    it "returns http success" do
      get :show, id: study.id
      expect(response).to have_http_status(:success)
    end

    it "shows the study"
  end
end
