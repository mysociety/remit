# encoding: utf-8
require "rails_helper"

RSpec.describe "public_activity/study/_erb_status_id_changed.html.erb",
               type: :view do
  let(:partial) { "public_activity/study/erb_status_id_changed" }
  let(:study) { FactoryGirl.create(:study) }
  let(:user) { FactoryGirl.create(:user) }
  let(:in_draft) do
    ErbStatus.find_by_name("In draft") || FactoryGirl.create(:in_draft)
  end
  let(:submitted) do
    ErbStatus.find_by_name("Submitted") || FactoryGirl.create(:submitted)
  end
  let(:activity_without_owner) do
    study.create_activity :erb_status_id_changed,
                          parameters: { before: in_draft.id,
                                        after: submitted.id },
                          owner: nil,
                          related_content: submitted
  end
  let(:activity_with_owner) do
    study.create_activity :erb_status_id_changed,
                          parameters: { before: in_draft.id,
                                        after: submitted.id },
                          owner: user,
                          related_content: submitted
  end

  before do
    PublicActivity.enabled = true
    render partial: partial,
           locals: { a: activity_with_owner, p: activity_with_owner.parameters }
  end

  after do
    PublicActivity.enabled = false
  end

  context "when the erb status is neutral" do
    it "is given neutral styling" do
      expect(view.content_for(:extra_classes)).to be nil
    end
  end

  context "when the erb status is good" do
    let(:accept) { FactoryGirl.create(:accept) }
    let(:positive_activity) do
      study.create_activity :erb_status_id_changed,
                            parameters: { before: in_draft.id,
                                          after: accept.id },
                            owner: nil,
                            related_content: accept
    end

    before do
      render partial: partial,
             locals: { a: positive_activity, p: positive_activity.parameters }
    end

    it "is given positive styling" do
      expected_class = "timeline__item--affirmative"
      expect(view.content_for(:extra_classes)).to have_text expected_class
    end
  end

  context "when the erb status is bad" do
    let(:reject) { FactoryGirl.create(:reject) }
    let(:negative_activity) do
      study.create_activity :erb_status_id_changed,
                            parameters: { before: in_draft.id,
                                          after: reject.id },
                            owner: nil,
                            related_content: reject
    end

    before do
      render partial: partial,
             locals: { a: negative_activity, p: negative_activity.parameters }
    end

    it "is given negative styling" do
      expected_class = "timeline__item--negative"
      expect(view.content_for(:extra_classes)).to have_text expected_class
    end
  end

  it "Sets the title from the status" do
    expect(view.content_for(:title)).to have_text submitted.description
  end

  it "Sets the description to say who updated it" do
    expected_text = "Updated by #{user.name}"
    expect(view.content_for(:description)).to have_text expected_text
  end
end
