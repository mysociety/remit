require "rails_helper"
require "support/devise.rb"

RSpec.describe "home/index.html.erb", type: :view do
  before do
    @studies = FactoryGirl.create_list(:study, 10)
    # The view expects to be able to paginate the the list of studies
    @studies = Kaminari.paginate_array(@studies).page(1).per(10)
    assign(:studies, @studies)
    render
  end

  it "shows the study titles" do
    @studies.each do |study|
      expect(rendered).to match(/#{Regexp.escape(study.title)}/)
    end
  end

  it "shows the study types" do
    @studies.each do |study|
      expect(rendered).to match(/#{Regexp.escape(study.study_type.name)}/)
    end
  end

  it "shows the PI when there is one" do
    pi = FactoryGirl.create(:user)
    @studies.first.principal_investigator = pi
    @studies.first.save!
    render
    expect(rendered).to match(/#{Regexp.escape(pi.name)}/)
  end

  it "shows the country when there is one" do
    @studies.first.country_codes = ["GB"]
    @studies.first.save!
    render
    expect(rendered).to match(/United Kingdom/)
  end

  it "shows multiple countries when there are many" do
    @studies.first.country_codes = %w(GB BD)
    @studies.first.save!
    render
    expect(rendered).to match(/United Kingdom and Bangladesh/)
  end
end
