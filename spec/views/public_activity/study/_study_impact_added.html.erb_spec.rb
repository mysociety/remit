# encoding: utf-8
require "rails_helper"
require "support/activity_view_shared_examples"

RSpec.describe "public_activity/study/_study_impact_added.html.erb",
               type: :view do
  let(:partial) { "public_activity/study/study_impact_added" }
  let(:study) { FactoryGirl.create(:study) }
  let(:impact) { FactoryGirl.create(:study_impact, study: study) }
  let(:user) { FactoryGirl.create(:user) }
  let(:activity_without_owner) do
    study.create_activity :study_impact_added,
                          owner: nil,
                          related_content: impact
  end
  let(:activity_with_owner) do
    study.create_activity :study_impact_added,
                          owner: user,
                          related_content: impact
  end

  let(:expected_class) { "timeline__item--affirmative" }
  let(:expected_title) { "#{impact.impact_type.name} impact added" }
  let(:expected_description) { "See details in full »" }
  let(:expected_description_class) { ".timeline__item__details" }

  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it_behaves_like "an activity view"
end
