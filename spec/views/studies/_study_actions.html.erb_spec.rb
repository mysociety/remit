require "rails_helper"

RSpec.shared_examples_for "content form view" do
  before do
    resource.valid?
    assign(:study, study)
    assign(resource_name, resource)
    render
  end

  it "prints an error message" do
    expect(rendered).to have_text expected_error
  end

  it "opens the right form" do
    expect(rendered).to have_checked_field(form_field)
  end
end

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

  context "when the publication form is invalid" do
    let(:resource_name) { :publication }
    let(:resource) do
      FactoryGirl.build(:publication, study: study, article_title: nil)
    end
    let(:expected_error) { "Article title can't be blank" }
    let(:form_field) { "add-output" }

    it_behaves_like "content form view"

    it "opens the publication subform" do
      resource.valid?
      assign(:study, study)
      assign(resource_name, resource)
      render
      expect(rendered).to have_checked_field("output-type-publication")
    end
  end

  context "when the dissemination form is invalid" do
    let(:resource_name) { :dissemination }
    let(:resource) do
      FactoryGirl.build(:dissemination, study: study, details: nil)
    end
    let(:expected_error) { "Details can't be blank" }
    let(:form_field) { "add-output" }

    it_behaves_like "content form view"

    it "opens the dissemination subform" do
      resource.valid?
      assign(:study, study)
      assign(resource_name, resource)
      render
      expect(rendered).to have_checked_field("output-type-dissemination")
    end
  end

  context "when the impact form is invalid" do
    context "when there's one invalid impact" do
      let(:study_impact) do
        FactoryGirl.build(:study_impact, study: study, description: nil)
      end

      before do
        study_impact.valid?
        assign(:study, study)
        assign(:study_impacts_errors, true)
        study_impacts = {
          study_impact.impact_type.id => study_impact
        }
        assign(:study_impacts, study_impacts)
        render
      end

      it "prints an error message" do
        expect(rendered).to have_text "Description can't be blank"
      end

      it "opens the output form" do
        expect(rendered).to have_checked_field("add-output")
      end

      it "opens the impact subform" do
        expect(rendered).to have_checked_field("output-type-other")
      end
    end

    context "when there are multiple invalid impacts" do
      let(:programme_impact) { FactoryGirl.create(:programme_impact) }
      let(:msf_policy_impact) { FactoryGirl.create(:msf_policy_impact) }
      let(:study_impact) do
        FactoryGirl.build(:study_impact, study: study,
                                         description: nil,
                                         impact_type: msf_policy_impact)
      end
      let(:study_impact_2) do
        FactoryGirl.build(:study_impact, study: study,
                                         description: nil,
                                         impact_type: programme_impact)
      end

      before do
        study_impact.valid?
        study_impact_2.valid?
        assign(:study, study)
        assign(:study_impacts_errors, true)
        study_impacts = {
          msf_policy_impact.id => study_impact,
          programme_impact.id => study_impact_2
        }
        assign(:study_impacts, study_impacts)
        render
      end

      it "prints an error message for each impact" do
        expect(rendered).to have_text("Description can't be blank", count: 2)
      end

      it "opens the output form" do
        expect(rendered).to have_checked_field("add-output")
      end

      it "opens the impact subform" do
        expect(rendered).to have_checked_field("output-type-other")
      end
    end
  end
end
