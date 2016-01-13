require "rails_helper"

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "lists all the studies"
    it "paginates the studies"
    it "sorts the studies"
  end
end
