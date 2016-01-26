# encoding: utf-8
require "rails_helper"

RSpec.describe "public_activity/study/_study_stage_changed.html.erb",
               type: :view do
  let(:partial) { "public_activity/study/study_stage_changed" }
  let(:study) { FactoryGirl.create(:study) }
  let(:user) { FactoryGirl.create(:user) }
  let(:activity_without_owner) do
    study.create_activity :study_stage_changed,
                          parameters: { before: study.study_stage,
                                        after: "protocol_erb" },
                          owner: nil
  end
  let(:activity_with_owner) do
    study.create_activity :study_stage_changed,
                          parameters: { before: study.study_stage,
                                        after: "protocol_erb" },
                          owner: user
  end

  before do
    PublicActivity.enabled = true
    render partial: partial,
           locals: { a: activity_with_owner, p: activity_with_owner.parameters }
  end

  after do
    PublicActivity.enabled = false
  end

  context "when the study has been postponed or withdrawn" do
    let(:postponed_activity) do
      study.create_activity :title_changed,
                            parameters: { before: study.study_stage,
                                          after: "withdrawn_postponed" },
                            owner: nil
    end

    before do
      render partial: partial,
             locals: { a: postponed_activity, p: postponed_activity.parameters }
    end

    it "is given negative styling" do
      expected_class = "timeline__item--negative"
      expect(view.content_for(:extra_classes)).to have_text expected_class
    end
  end

  context "when the study has changed to any other stage" do
    it "is given positive styling" do
      expected_class = "timeline__item--affirmative"
      expect(view.content_for(:extra_classes)).to have_text expected_class
    end
  end

  it "Sets the title" do
    expect(view.content_for(:title)).to have_text "Concept note approved"
  end

  it "Sets the description" do
    expect(view.content_for(:description)).to be nil
  end
end
