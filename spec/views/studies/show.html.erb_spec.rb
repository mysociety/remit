# encoding: utf-8
require "rails_helper"
require "support/devise.rb"

RSpec.describe "studies/show.html.erb", type: :view do
  let(:study) { FactoryGirl.create(:study) }

  before do
    assign(:study, study)
    render
  end

  it "shows the study title" do
    expect(rendered).to match(/#{Regexp.escape(study.title)}/)
  end

  it "shows the study stage" do
    expect(rendered).to match(/#{Regexp.escape(study.study_stage_label)}/)
  end

  it "shows the study stage since date" do
    expected_date = study.study_stage_since.to_formatted_s(:short_ordinal)
    expect(rendered).to match(/Since #{Regexp.escape(expected_date)}/)
  end

  it "shows the study topic" do
    topic = study.study_topics.first.name
    expect(rendered).to match(/#{Regexp.escape(topic)}/)
  end

  it "shows the study type" do
    expect(rendered).to match(/#{Regexp.escape(study.study_type.name)}/)
  end

  it "shows the country when there is one" do
    study.country_codes = ["GB"]
    study.save!
    render
    expect(rendered).to match(/United Kingdom/)
  end

  it "shows multiple countries when there are many" do
    study.country_codes = %w(GB BD)
    study.save!
    render
    expect(rendered).to match(/United Kingdom and Bangladesh/)
  end

  it "shows the pi when there is one" do
    pi = FactoryGirl.create(:user)
    pi_study = FactoryGirl.create(:study, principal_investigator: pi)
    assign(:study, pi_study)
    render
    expect(rendered).to match(/#{Regexp.escape(pi.name)}/)
  end

  describe "admin edit link" do
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    let(:normal_user) { FactoryGirl.create(:user) }
    let(:edit_text) { "Edit study details" }

    it "isn't shown to anonymous users" do
      sign_out :user
      render
      expect(rendered).not_to match(/#{edit_text}/)
    end

    it "isn't shown to normal users" do
      sign_in normal_user
      render
      expect(rendered).not_to match(/#{edit_text}/)
    end

    it "is shown to admin users" do
      sign_in admin_user
      render
      expect(rendered).to match(/#{edit_text}/)
    end
  end

  describe "documents sidebar" do
    let(:document_type) { FactoryGirl.create(:document_type) }

    it "links to the files" do
      documents = FactoryGirl.create_list(:document,
                                          5,
                                          study: study,
                                          document_type: document_type)
      assign(:study, study.reload)
      render
      documents.each do |document|
        expected_text = "#{document.document_file_name} " \
                        "#{number_to_human_size(document.document_file_size)}"
        expected_url = document.document.url
        expect(rendered).to have_link expected_text, href: expected_url
      end
    end

    it "prints an empty message when there are no documents" do
      assign(:study, FactoryGirl.create(:study))
      render
      expect(rendered).to have_text "No documents uploaded"
    end
  end

  describe "publications sidebar" do
    it "displays each publication" do
      publications = FactoryGirl.create_list(:publication, 5, study: study)
      assign(:study, study.reload)
      render
      publications.each do |publication|
        expected_text = "#{publication.article_title} " \
                        "#{publication.lead_author} – "\
                        "#{publication.book_or_journal_title} " \
                        "(#{publication.publication_year})"
        expect(rendered).to have_text expected_text
      end
    end

    it "prints an empty message when there are no publications" do
      assign(:study, FactoryGirl.create(:study))
      render
      expect(rendered).to have_text "No publications recorded"
    end
  end
end
