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

  it "sets total_studies" do
    get action, params
    expect(assigns[:total_studies]).to eq 20
  end
end
