# encoding: utf-8
require "rails_helper"
require "support/shared_examples/views/activities"

# rubocop:disable Metrics/LineLength
RSpec.describe "public_activity/study/_principal_investigator_id_changed.html.erb", type: :view do
  # rubocop:enable Metrics/LineLength
  let(:partial) { "public_activity/study/principal_investigator_id_changed" }
  let(:study) { FactoryGirl.create(:study) }
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:activity_without_owner) do
    study.create_activity :principal_investigator_id_changed,
                          parameters: { before: nil, after: user2.id },
                          recipient: user2,
                          owner: nil
  end
  let(:activity_with_owner) do
    study.create_activity :principal_investigator_id_changed,
                          parameters: { before: nil, after: user2.id },
                          recipient: user2,
                          owner: user
  end
  let(:expected_class) { nil }
  let(:expected_title) { "Principal investigator changed" }
  let(:expected_description) { "Changed to “#{user2.name}”" }
  let(:expected_description_class) { ".timeline__item__details" }

  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it_behaves_like "an activity view"

  context "when the user was removed" do
    let(:removed_activity) do
      study.create_activity :principal_investigator_id_changed,
                            parameters: { before: user2.id, after: nil },
                            recipient: nil,
                            owner: user
    end

    before do
      render partial: partial,
             locals: { a: removed_activity,
                       p: removed_activity.parameters }
    end

    it "sets the title to say that they were removed" do
      expected_text = "Principal investigator removed by #{user.name}"
      expect(view.content_for(:title)).to have_text expected_text
    end

    it "doesn't set a description" do
      expect(view.content_for(:description)).to be nil
    end
  end
end
