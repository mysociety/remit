require "rails_helper"
require "support/devise.rb"

RSpec.describe "studies/show.html.erb", type: :view do
  before do
    @study = FactoryGirl.create(:study)
    assign(:study, @study)
    render
  end

  it "shows the study title" do
    expect(rendered).to match(/#{Regexp.escape(@study.title)}/)
  end

  it "shows the study stage" do
    expect(rendered).to match(/#{Regexp.escape(@study.study_stage_label)}/)
  end

  it "shows the study stage since date" do
    expected_date = @study.study_stage_since.to_formatted_s(:short_ordinal)
    expect(rendered).to match(/Since #{Regexp.escape(expected_date)}/)
  end

  it "shows the study topic" do
    topic = @study.study_topics.first.name
    expect(rendered).to match(/#{Regexp.escape(topic)}/)
  end

  it "shows the study type" do
    expect(rendered).to match(/#{Regexp.escape(@study.study_type.name)}/)
  end

  it "shows the country when there is one" do
    @study.country_codes = ["GB"]
    @study.save!
    render
    expect(rendered).to match(/United Kingdom/)
  end

  it "shows multiple countries when there are many" do
    @study.country_codes = %w(GB BD)
    @study.save!
    render
    expect(rendered).to match(/United Kingdom and Bangladesh/)
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
