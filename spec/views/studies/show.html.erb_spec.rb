# encoding: utf-8
require "rails_helper"
require "support/devise"

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
    expect(rendered).to match(/United Kingdom/)
    expect(rendered).to match(/Bangladesh/)
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

  describe "add impact link" do
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    let(:normal_user) { FactoryGirl.create(:user) }
    let(:impact_link) do
      "Record a dissemination or other impact for this study"
    end

    it "isn't shown to anonymous users" do
      sign_out :user
      render
      expect(rendered).not_to have_text(impact_link)
    end

    it "isn't shown to normal users" do
      sign_in normal_user
      render
      expect(rendered).not_to have_text(impact_link)
    end

    it "is shown to admin users" do
      sign_in admin_user
      render
      expect(rendered).to have_text(impact_link)
    end

    it "is shown to pi's of the study" do
      study.principal_investigator = normal_user
      study.save!
      sign_in normal_user
      render
      expect(rendered).to have_text(impact_link)
    end

    it "is shown to rm's of the study" do
      study.research_manager = normal_user
      study.save!
      sign_in normal_user
      render
      expect(rendered).to have_text(impact_link)
    end
  end

  describe "Invite users form" do
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    let(:normal_user) { FactoryGirl.create(:user) }
    let(:invite_link) { "Invite someone else to record an impact" }

    it "isn't shown to anonymous users" do
      sign_out :user
      render
      expect(rendered).not_to have_text(invite_link)
    end

    it "isn't shown to normal users" do
      sign_in normal_user
      render
      expect(rendered).not_to have_text(invite_link)
    end

    it "is shown to admin users" do
      sign_in admin_user
      render
      expect(rendered).to have_text(invite_link)
    end

    it "is shown to pi's of the study" do
      study.principal_investigator = normal_user
      study.save!
      sign_in normal_user
      render
      expect(rendered).to have_text(invite_link)
    end

    it "is shown to rm's of the study" do
      study.research_manager = normal_user
      study.save!
      sign_in normal_user
      render
      expect(rendered).to have_text(invite_link)
    end

    it "is expanded when there's an error" do
      study.principal_investigator = normal_user
      study.save!
      study_invite = FactoryGirl.build(:study_invite, invited_user: nil)
      study_invite.valid?
      assign(:study_invite, study_invite)
      sign_in normal_user
      render
      label = "Invite someone else to record an impact"
      expect(rendered).to have_checked_field(label)
    end
  end

  describe "study actions bar" do
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    let(:normal_user) { FactoryGirl.create(:user) }

    it "isn't shown to anonymous users" do
      sign_out :user
      render
      expect(view).not_to render_template(partial: "studies/_study_actions")
    end

    it "isn't shown to normal users" do
      sign_in normal_user
      render
      expect(view).not_to render_template(partial: "studies/_study_actions")
    end

    it "is shown to admin users" do
      sign_in admin_user
      render
      expect(view).to render_template(partial: "studies/_study_actions")
    end

    it "is shown to pi's of the study" do
      study.principal_investigator = normal_user
      study.save!
      sign_in normal_user
      render
      expect(view).to render_template(partial: "studies/_study_actions")
    end

    it "is shown to rm's of the study" do
      study.research_manager = normal_user
      study.save!
      sign_in normal_user
      render
      expect(view).to render_template(partial: "studies/_study_actions")
    end
  end

  describe "add delivery update link" do
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    let(:normal_user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:update_link) do
      "Add delivery update for this study"
    end
    let!(:invite) do
      FactoryGirl.create(:delivery_update_invite, study: study,
                                                  invited_user: normal_user)
    end

    it "is shown to invited users" do
      study.principal_investigator = normal_user
      study.save!
      sign_in normal_user
      render
      expect(rendered).to have_text(update_link)
    end

    it "isn't shown to other users" do
      sign_in other_user
      render
      expect(rendered).not_to have_text(update_link)
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
        expected_url = document_path(document)
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
