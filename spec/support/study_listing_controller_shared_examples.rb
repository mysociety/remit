require "rails_helper"

RSpec.shared_examples_for "study listing controller" do
  it "lists the studies" do
    get action, params
    expect(assigns[:studies]).to match_array(studies.last(10))
  end

  it "paginates the studies" do
    get action, params.merge(page: 2)
    expect(assigns[:studies]).to match_array(studies.first(10))
  end

  describe "#set_study_scope" do
    it "sets study_scope" do
      get action, params
      expect(assigns[:study_scope]).to eq :not_archived_or_withdrawn
    end

    context "when the user asks for archived studies too" do
      before do
        params[:include_archived] = 1
      end

      it "sets study_scope" do
        get action, params
        expect(assigns[:study_scope]).to eq :not_withdrawn
      end
    end
  end

  describe "#set_include_archived" do
    it "sets include_archived" do
      get action, params
      expect(assigns[:include_archived]).to be false
    end

    context "when the user asks for archived studies too" do
      before do
        params[:include_archived] = 1
      end

      it "sets study_scope" do
        get action, params
        expect(assigns[:include_archived]).to be true
      end
    end
  end
end
