# encoding: utf-8
require "rails_helper"
require "support/shared_examples/views/activities"

RSpec.describe "public_activity/study/_title_changed.html.erb", type: :view do
  let(:partial) { "public_activity/study/title_changed" }
  let(:study) { FactoryGirl.create(:study) }
  let(:user) { FactoryGirl.create(:user) }
  let(:activity_without_owner) do
    study.create_activity :title_changed,
                          parameters: { before: "Before", after: "After" },
                          owner: nil
  end
  let(:activity_with_owner) do
    study.create_activity :title_changed,
                          parameters: { before: "Before", after: "After" },
                          owner: user
  end
  let(:expected_class) { nil }
  let(:expected_title) { "Title changed" }
  let(:expected_description) { "Changed to “After”" }
  let(:expected_description_class) { ".timeline__item__details" }

  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it_behaves_like "an activity view"
end
