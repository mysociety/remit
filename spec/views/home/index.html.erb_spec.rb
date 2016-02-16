require "rails_helper"
require "support/devise"

RSpec.describe "home/index.html.erb", type: :view do
  before do
    @studies = FactoryGirl.create_list(:study, 10)
    # The view expects to be able to paginate the the list of studies
    @studies = Kaminari.paginate_array(@studies).page(1).per(10)
    assign(:studies, @studies)
    @study_types = []
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

  context "when the user is logged in" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      render
    end

    it "shows 'Your studies' tab" do
      expected_path = user_studies_path(user)
      expect(rendered).to have_link("Your studies", href: expected_path)
    end

    it "shows 'Studies you're following' tab" do
      expected_path = user_studies_path(user)
      expect(rendered).to have_link("Your studies", href: expected_path)
    end
  end

  context "when the user isn't logged in" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_out :user
      render
    end

    it "doesn't show 'Your studies' tab" do
      expected_path = user_studies_path(user)
      expect(rendered).not_to have_link("Your studies", href: expected_path)
    end

    it "doesn't show 'Studies you're following' tab" do
      expected_path = user_studies_path(user)
      expect(rendered).not_to have_link("Your studies", href: expected_path)
    end
  end
end
