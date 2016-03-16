require "rails_helper"
require "support/shared_examples/features/listing_studies"

RSpec.describe "Homepage" do
  it "exists" do
    visit root_path
    expect(page).to have_text("ReMIT")
  end

  context "when there are some studies" do
    let(:expected_studies) { FactoryGirl.create_list(:study, 20) }
    let(:path) { root_path }

    it_behaves_like "study listing page"
  end
end
