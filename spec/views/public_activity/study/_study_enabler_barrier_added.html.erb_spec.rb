# encoding: utf-8
require "rails_helper"
require "support/shared_examples/views/activities"

RSpec.describe "public_activity/study/_study_enabler_barrier_added.html.erb",
               type: :view do
  let(:partial) { "public_activity/study/study_enabler_barrier_added" }
  let(:study) { FactoryGirl.create(:study) }
  let(:enabler_barrier) do
    FactoryGirl.create(:study_enabler_barrier,
                       study: study,
                       description: "Test enabler barrier")
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
  let(:expected_description) { enabler_barrier.description }
  let(:expected_description_class) { ".timeline__item__enabler-barrier" }

  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it_behaves_like "an activity view"
end
