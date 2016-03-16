# encoding: utf-8
require "rails_helper"
require "support/shared_examples/views/activities"

RSpec.describe "public_activity/study/_study_note_added.html.erb",
               type: :view do
  let(:partial) { "public_activity/study/study_note_added" }
  let(:study) { FactoryGirl.create(:study) }
  let(:note) { FactoryGirl.create(:study_note, study: study) }
  let(:user) { FactoryGirl.create(:user) }
  let(:activity_without_owner) do
    study.create_activity :study_note_added,
                          owner: nil,
                          related_content: note
  end
  let(:activity_with_owner) do
    study.create_activity :study_note_added,
                          owner: user,
                          related_content: note
  end

  let(:expected_class) { nil }
  let(:expected_title) { "Note left" }
  let(:expected_description) { note.notes }
  let(:expected_description_class) { ".timeline__item__note" }

  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it_behaves_like "an activity view"
end
