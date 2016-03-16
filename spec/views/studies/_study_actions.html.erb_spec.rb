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

  context "when the enabler/barrier form is invalid" do
    context "when there's one invalid enabler/barrier" do
      let(:study_enabler_barrier) do
        FactoryGirl.build(:study_enabler_barrier, study: study,
                                                  description: nil)
      end

      before do
        study_enabler_barrier.valid?
        assign(:study, study)
        assign(:study_enabler_barriers_errors, true)
        study_enabler_barriers = {
          study_enabler_barrier.enabler_barrier.id => study_enabler_barrier
        }
        assign(:study_enabler_barriers, study_enabler_barriers)
        render
      end

      it "prints an error message" do
        expect(rendered).to have_text "Description can't be blank"
      end

      it "opens the output form" do
        expect(rendered).to have_checked_field("add-enabler-barrier")
      end
    end

    context "when there are multiple invalid enabler/barrier" do
      let(:delivery_barrier) { FactoryGirl.create(:delivery_barrier) }
      let(:patient_barrier) { FactoryGirl.create(:patient_barrier) }
      let(:study_enabler_barrier) do
        FactoryGirl.build(
          :study_enabler_barrier,
          study: study,
          description: nil,
          enabler_barrier: delivery_barrier)
      end
      let(:study_enabler_barrier_2) do
        FactoryGirl.build(
          :study_enabler_barrier,
          study: study,
          description: nil,
          enabler_barrier: patient_barrier)
      end

      before do
        study_enabler_barrier.valid?
        study_enabler_barrier_2.valid?
        assign(:study, study)
        assign(:study_enabler_barriers_errors, true)
        study_enabler_barriers = {
          study_enabler_barrier.enabler_barrier.id => study_enabler_barrier,
          study_enabler_barrier_2.enabler_barrier.id => study_enabler_barrier_2
        }
        assign(:study_enabler_barriers, study_enabler_barriers)
        render
      end

      it "prints an error message" do
        expect(rendered).to have_text("Description can't be blank", count: 2)
      end

      it "opens the output form" do
        expect(rendered).to have_checked_field("add-enabler-barrier")
      end
    end
  end
end
