require "rails_helper"

RSpec.describe "Homepage" do
  it "exists" do
    visit "/"
    expect(page).to have_text("ReMIT")
  end
end
