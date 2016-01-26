# encoding: utf-8
require "rails_helper"
require "support/activity_view_shared_examples"

RSpec.describe "public_activity/study/_publication_added.html.erb",
               type: :view do
  let(:partial) { "public_activity/study/publication_added" }
  let(:study) { FactoryGirl.create(:study) }
  let(:publication) { FactoryGirl.create(:publication, study: study) }
  let(:user) { FactoryGirl.create(:user) }
  let(:activity_without_owner) do
    study.create_activity :publication_added,
                          owner: nil,
                          related_content: publication
  end
  let(:activity_with_owner) do
    study.create_activity :publication_added,
                          owner: user,
                          related_content: publication
  end
  let(:expected_class) { "timeline__item--affirmative" }
  let(:expected_title) { "Publication added" }
  let(:expected_description) { "Read publication »" }
  let(:expected_description_class) { ".timeline__item__details" }

  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it_behaves_like "an activity view"
end
