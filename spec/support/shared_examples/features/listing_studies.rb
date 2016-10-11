require "rails_helper"

# Expects you to supply 20 studies and a path that they'll be listed on
RSpec.shared_examples_for "study listing page" do
  before do
    # Make some studies active
    expected_studies.first.study_stage = :delivery
    expected_studies.first.protocol_needed = false
    expected_studies.first.save!
    expected_studies.second.study_stage = :delivery
    expected_studies.second.protocol_needed = false
    expected_studies.second.save!
    expected_studies.third.study_stage = :delivery
    expected_studies.third.protocol_needed = false
    expected_studies.third.save!

    # Add locations to some studies
    expected_studies.first.country_codes = %w{GB}
    expected_studies.first.save!
    expected_studies.second.country_codes = %w{SM}
    expected_studies.second.save!
    expected_studies.third.country_codes = %w{BD}
    expected_studies.third.save!

    # Create some impact
    FactoryGirl.create(:publication, study: expected_studies.first)
    FactoryGirl.create(:dissemination, study: expected_studies.first)
    FactoryGirl.create(:study_impact, study: expected_studies.first)
    FactoryGirl.create(:dissemination, study: expected_studies.second)
    FactoryGirl.create(:study_impact, study: expected_studies.third)

    # Re-sort the studies to make sure they match the way the view will sort
    # them.
    expected_studies.sort! { |a, b| a.created_at <=> b.created_at }
  end

  it "shows study and location counts" do
    visit(path)
    expect(page).to have_text "3 studies"
    expect(page).to have_text "3 locations"
    expect(page).to have_text "3 studies with recorded impact"
  end

  describe "pagination" do
    it "shows the range of studies on the page" do
      visit(path)
      expect(page).to have_text "Displaying studies 1 - 10 of 20 in total by"
      visit("#{path}?page=2")
      expect(page).to have_text "Displaying studies 11 - 20 of 20 in total by"
    end

    it "allows the user to navigate the pages" do
      visit(path)
      expected_studies.last(10).each do |study|
        expect(page).to have_link(study.title, href: study_path(study))
      end
      click_link("2", href: "#{path}?page=2")
      expected_studies.first(10).each do |study|
        expect(page).to have_link(study.title, href: study_path(study))
      end
    end
  end
end
