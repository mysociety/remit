# encoding: utf-8
require "rails_helper"
require "support/user_account_feature_helper"
require "support/matchers/have_latest_activity"
require "support/matchers/match_activity"

def click_label(text)
  find("label", text: text).click
end

RSpec.shared_examples_for "Adding impact to a study" do
  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it "allows you to contribute a publication manually" do
    choose("output-type-publication")
    click_label("Or enter details manually…")
    fill_in "Article title", with: "A test article"
    fill_in "Lead author", with: "A test author"
    fill_in "Publication title", with: "A test publication"
    fill_in "Publication year", with: "2015"
    click_button "Add output"

    publication = Publication.find_by_article_title("A test article")

    expect(page).to have_text "Publication created successfully"

    expect(publication).not_to be nil
    expect(publication.study).to eq study
    expect(publication.user).to eq expected_user
    expect(study).to have_latest_activity(key: "study.publication_added",
                                          owner: expected_user)
  end

  it "allows you to contribute a publication by DOI number" do
    # This is easier than setting up a whole VCR setup for this one api call
    successful_doi_result = BibTeX::Entry.new(title: "Test journal article",
                                              journal: "Test journal",
                                              year: "1953",
                                              author: "Test author et al")
    expect(BibURI).to receive(:lookup).and_return(successful_doi_result)

    choose("output-type-publication")
    fill_in "DOI", with: "doi:1234"
    click_button "Add output"

    publication = Publication.find_by_article_title("Test journal article")

    expect(page).to have_text "Publication created successfully"

    expect(publication).not_to be nil
    expect(publication.study).to eq study
    expect(publication.user).to eq expected_user
    expect(publication.book_or_journal_title).to eq "Test journal"
    expect(publication.publication_year).to eq 1953
    expect(publication.lead_author).to eq "Test author et al"
    expect(study).to have_latest_activity(key: "study.publication_added",
                                          owner: expected_user)
  end

  it "allows you to contribute a dissemination that hasn't been fed back" do
    choose("output-type-dissemination")
    select dissemination_category.name, from: "Dissemination category"
    fill_in "Describe the dissemination", with: "A test dissemination"
    fed_back_label = "How have you fed back to people in the country or " \
                     "region where the study was conducted?"
    fill_in fed_back_label, with: "Some description"
    click_button "Add output"

    dissemination = Dissemination.find_by_details("A test dissemination")

    expect(page).to have_text "Dissemination created successfully"

    expect(dissemination).not_to be nil
    expect(dissemination.fed_back_to_field).to eq "Some description"
    expect(dissemination.study).to eq study
    expect(dissemination.user).to eq expected_user
    expect(study).to have_latest_activity(key: "study.dissemination_added",
                                          owner: expected_user)
  end

  it "allows you to add an other category without js" do
    details = "A test fed back dissemination"
    other_category = "Some other category"

    choose("output-type-dissemination")
    select DisseminationCategory.other_internal_category.name,
           from: "Dissemination category"
    fill_in "If 'Other', describe the category in a couple of words",
            with: other_category
    fill_in "Describe the dissemination", with: details
    fed_back_label = "How have you fed back to people in the country or " \
                     "region where the study was conducted?"
    fill_in fed_back_label, with: "Some description"
    click_button "Add output"

    dissemination = Dissemination.find_by_details(details)

    expect(page).to have_text "Dissemination created successfully"

    expect(dissemination).not_to be nil
    expect(dissemination.other_dissemination_category).to eq other_category
    expect(dissemination.fed_back_to_field).to eq "Some description"
    expect(dissemination.study).to eq study
    expect(dissemination.user).to eq expected_user
    expect(study).to have_latest_activity(key: "study.dissemination_added",
                                          owner: expected_user)
  end

  it "allows you to contribute a single impact" do
    choose("output-type-other")
    check "MSF Policy"
    fill_in "study_impact[descriptions][#{msf_policy_impact_type.id}]",
            with: "Test MSF policy impact"
    click_button "Add output"

    impact = StudyImpact.find_by_description("Test MSF policy impact")

    expect(page).to have_text "1 Impact created successfully"

    expect(impact).not_to be nil
    expect(impact.study).to eq study
    expect(impact.user).to eq expected_user
    expect(impact.impact_type).to eq msf_policy_impact_type

    expect(study).to have_latest_activity(key: "study.study_impact_added",
                                          owner: expected_user)
  end

  it "allows you to contribute multiple impacts" do
    choose("output-type-other")
    check "MSF Policy"
    fill_in "study_impact[descriptions][#{msf_policy_impact_type.id}]",
            with: "Test MSF policy impact"
    check "Programmes"
    fill_in "study_impact[descriptions][#{programme_impact_type.id}]",
            with: "Test program impact"
    click_button "Add output"

    msf_impact = StudyImpact.find_by_description("Test MSF policy impact")
    program_impact = StudyImpact.find_by_description("Test program impact")

    expect(page).to have_text "2 Impacts created successfully"

    expect(msf_impact).not_to be nil
    expect(msf_impact.study).to eq study
    expect(msf_impact.user).to eq expected_user
    expect(msf_impact.impact_type).to eq msf_policy_impact_type

    expect(program_impact).not_to be nil
    expect(program_impact.study).to eq study
    expect(program_impact.user).to eq expected_user
    expect(program_impact.impact_type).to eq programme_impact_type

    activities = study.activities.first(2)

    expect(activities[0]).to match_activity(key: "study.study_impact_added",
                                            owner: expected_user,
                                            related_content: msf_impact)
    expect(activities[1]).to match_activity(key: "study.study_impact_added",
                                            owner: expected_user,
                                            related_content: program_impact)
  end
end

RSpec.describe "Adding impact to a study" do
  let!(:user) { FactoryGirl.create(:normal_user) }
  let!(:study) { FactoryGirl.create(:study, principal_investigator: user) }
  let!(:dissemination_category) { FactoryGirl.create(:field) }
  let!(:msf_policy_impact_type) { FactoryGirl.create(:msf_policy_impact) }
  let!(:programme_impact_type) { FactoryGirl.create(:programme_impact) }

  context "as a logged in user" do
    let(:expected_user) { user }
    before do
      sign_in_account(user.email)
      visit study_path(study)
      find(:xpath, "//a[@href='#{study_outputs_new_path(study)}']").click
    end

    it_behaves_like "Adding impact to a study"
  end

  context "as a user invited by email" do
    let!(:invited_user) { FactoryGirl.create(:user) }
    let(:expected_user) { invited_user }
    let!(:study_invite) do
      FactoryGirl.create(:study_invite, study: study,
                                        invited_user: invited_user,
                                        inviting_user: user)
    end

    before do
      path = study_outputs_new_path(study)
      visit "#{path}?token=#{invited_user.invite_token}"
    end

    it_behaves_like "Adding impact to a study"
  end
end
