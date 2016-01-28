# encoding: utf-8
require "rails_helper"
require "support/activity_view_shared_examples"

RSpec.describe "public_activity/study/_created.html.erb", type: :view do
  let(:partial) { "public_activity/study/created" }
  let(:study) { FactoryGirl.create(:study) }
  let(:user) { FactoryGirl.create(:user) }
  let(:activity_without_owner) { study.create_activity :created, owner: nil }
  let(:activity_with_owner) { study.create_activity :created, owner: user }
  let(:expected_class) { nil }
  let(:expected_title) { "Study created" }
  let(:expected_description) { nil }

  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it_behaves_like "an activity view"

  context "when the title has changed" do
    before do
      study.title = "Some new title"
      study.save!
      render partial: partial,
             locals: { a: activity_with_owner,
                       p: activity_with_owner.parameters }
    end

    it "shows the original title in the description" do
      expected_text = "Originally titled “#{study.original_title}”"
      expect(view.content_for(:description)).to have_text expected_text
    end
  end
end
