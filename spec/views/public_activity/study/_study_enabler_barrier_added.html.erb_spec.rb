# encoding: utf-8
require "rails_helper"
require "support/activity_view_shared_examples"

RSpec.describe "public_activity/study/_study_enabler_barrier_added.html.erb",
               type: :view do
  let(:partial) { "public_activity/study/study_enabler_barrier_added" }
  let(:study) { FactoryGirl.create(:study) }
  let(:enabler_barrier) do
    FactoryGirl.create(:study_enabler_barrier, study: study)
  end
  let(:user) { FactoryGirl.create(:user) }
  let(:activity_without_owner) do
    study.create_activity :study_enabler_barrier_added,
                          owner: nil,
                          related_content: enabler_barrier
  end
  let(:activity_with_owner) do
    study.create_activity :study_enabler_barrier_added,
                          owner: user,
                          related_content: enabler_barrier
  end

  let(:expected_class) { "timeline__item--affirmative" }
  let(:expected_title) { "#{enabler_barrier.enabler_barrier.name} added" }
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
