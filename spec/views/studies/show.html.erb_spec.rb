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
    expect(rendered).to match(/#{Regexp.escape(study.study_stage.name)}/)
  end

  it "shows the study topic" do
    expect(rendered).to match(/#{Regexp.escape(study.study_topic.name)}/)
  end

  it "shows the study type" do
    expect(rendered).to match(/#{Regexp.escape(study.study_type.name)}/)
  end

  it "shows the country when there is one" do
    study.country_code = "GB"
    study.save!
    render
    expect(rendered).to match(/United Kingdom/)
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
end
