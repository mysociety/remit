require "rails_helper"
require "support/shared_examples/views/content_forms"

RSpec.describe "studies/_study_actions.html.erb", type: :view do
  let(:study) { FactoryGirl.create(:study) }

  context "when the document form is invalid" do
    let(:resource_name) { :document }
    let(:resource) do
      FactoryGirl.build(:document, study: study, document: nil)
    end
    let(:expected_error) { "Document can't be blank" }
    let(:form_field) { "add-document" }

    it_behaves_like "content form view"
  end

  context "when the note form is invalid" do
    let(:resource_name) { :study_note }
    let(:resource) { FactoryGirl.build(:study_note, study: study, notes: nil) }
    let(:expected_error) { "Notes can't be blank" }
    let(:form_field) { "add-note" }

    it_behaves_like "content form view"
  end
end
