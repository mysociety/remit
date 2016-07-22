require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#study_timeline" do
    let(:accept_status) { FactoryGirl.create(:accept) }
    let(:base_timeline) do
      {
        concept: { label: "Concept", state: "todo" },
        protocol_erb: { label: "Protocol & ERB", state: "todo" },
        delivery: { label: "Delivery", state: "todo" },
        completion: { label: "Completion", state: "todo" },
      }
    end

    context "given a study with no history" do
      context "when the study is in the concept stage" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with one entry" do
          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when the study is in the protocol_erb stage" do
        let(:study) do
          FactoryGirl.create(:study, study_stage: "protocol_erb",
                                     erb_status: accept_status)
        end

        it "returns a timeline with multiple entries" do
          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when the study is in the completion stage" do
        let(:study) do
          FactoryGirl.create(:study, study_stage: "completion",
                                     erb_status: accept_status)
        end

        it "returns a timeline with multiple entries" do
          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          expected_timeline[:completion][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when the study is in the withdrawn stage" do
        let(:study) do
          FactoryGirl.create(:study, study_stage: "withdrawn_postponed")
        end

        it "returns a timeline with two entries" do
          expect(study.withdrawn_postponed?).to be true
          expected_withdrawn_timeline = {
            concept: {
              label: "Concept",
              state: "done"
            },
            withdrawn_postponed: {
              label: "Withdrawn or Postponed",
              state: "doing"
            }
          }
          expect(study_timeline(study)).to eq expected_withdrawn_timeline
        end
      end

      context "when the study is archived" do
        let(:study) do
          FactoryGirl.create(
            :study,
            study_stage: "completion",
            completed: Time.zone.today - (5.years + 1.day),
            protocol_needed: false)
        end

        it "returns a timeline with multiple entries" do
          expect(study.archived?).to be true
          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          expected_timeline[:completion][:state] = "done"
          expected_timeline[:archived] = { label: "Archived", state: "doing" }
          expect(study_timeline(study)).to eq expected_timeline
        end
      end
    end

    context "given a study with history" do
      let(:study) { FactoryGirl.create(:study) }

      before do
        PublicActivity.enabled = true
      end

      after do
        PublicActivity.enabled = false
      end

      context "when the study is in the concept stage" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with one entry" do
          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when the study is in the protocol_erb stage" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with multiple entries" do
          study.study_stage = "protocol_erb"
          study.erb_status = accept_status
          study.save!

          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when the study is in the completion stage" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with multiple entries" do
          study.study_stage = "protocol_erb"
          study.erb_status = accept_status
          study.save!
          study.study_stage = "delivery"
          study.save!
          study.study_stage = "completion"
          study.save!

          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          expected_timeline[:completion][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when a study has skipped a stage" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with multiple entries" do
          study.erb_status = accept_status
          study.study_stage = "delivery"
          study.save!
          study.study_stage = "completion"
          study.save!

          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          # We expect the helper to fill this in for us anyway
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          expected_timeline[:completion][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when a study is in the withdrawn stage" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with entries only for completed stages" do
          study.study_stage = "protocol_erb"
          study.erb_status = accept_status
          study.save!
          study.study_stage = "delivery"
          study.save!
          study.study_stage = "withdrawn_postponed"
          study.save!

          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          # We expect the helper to delete this one
          expected_timeline.delete(:completion)
          expected_timeline[:withdrawn_postponed] = {
            label: "Withdrawn or Postponed",
            state: "doing"
          }
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when the study is archived" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with multiple entries" do
          study.study_stage = "protocol_erb"
          study.erb_status = accept_status
          study.save!
          study.study_stage = "delivery"
          study.save!
          study.study_stage = "completion"
          study.completed = Time.zone.today - (5.years + 1.day)
          study.save!

          expect(study.archived?).to be true

          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          expected_timeline[:completion][:state] = "done"
          expected_timeline[:archived] = { label: "Archived", state: "doing" }
          expect(study_timeline(study)).to eq expected_timeline
        end
      end
    end
  end

  describe "#study_stage_transition" do
    let(:non_final_stages) do
      Study.study_stages.select do |s|
        s != "withdrawn_postponed" && s != "completed"
      end
    end

    context "when the after stage is withdrawn" do
      it "returns 'Study was withdrawn or postponed'" do
        non_final_stages.each do |stage|
          expected_text = "Study was withdrawn or postponed"
          actual_text = study_stage_transition(stage, "withdrawn_postponed")
          expect(actual_text).to eq expected_text
        end
      end
    end

    context "when the after stage is completed" do
      it "returns 'Study completed'" do
        non_final_stages.each do |stage|
          expected_text = "Study completed"
          actual_text = study_stage_transition(stage, "completion")
          expect(actual_text).to eq expected_text
        end
      end
    end

    context "when the before stage is concept" do
      it "returns 'Concept note approved'" do
        non_final_stages.each do |stage|
          expected_text = "Concept note approved"
          actual_text = study_stage_transition("concept", stage)
          expect(actual_text).to eq expected_text
        end
      end
    end

    context "when the before stage is protocol" do
      it "returns 'Protocol passed ERB'" do
        non_final_stages.each do |stage|
          expected_text = "Protocol passed ERB"
          actual_text = study_stage_transition("protocol_erb", stage)
          expect(actual_text).to eq expected_text
        end
      end
    end

    context "when the before stage is delivery" do
      it "returns 'Delivery ended'" do
        non_final_stages.each do |stage|
          expected_text = "Study delivery ended"
          actual_text = study_stage_transition("delivery", stage)
          expect(actual_text).to eq expected_text
        end
      end
    end

    context "when the stages are nil" do
      it "returns nil" do
        expect(study_stage_transition).to be nil
      end
    end
  end

  describe "#total_not_archived_or_withdrawn_studies" do
    it "returns the total number of non archived or withdrawn studies" do
      FactoryGirl.create_list(:study, 5, study_stage: :completion,
                                         protocol_needed: false,
                                         completed: 6.years.ago)
      FactoryGirl.create_list(:study, 5, study_stage: :withdrawn_postponed,
                                         protocol_needed: false)
      FactoryGirl.create_list(:study, 5)
      expect(total_not_archived_or_withdrawn_studies).to eq 5
    end
  end

  describe "#total_not_withdrawn_studies" do
    it "returns the total number of non withdrawn studies" do
      FactoryGirl.create_list(:study, 5, study_stage: :completion,
                                         protocol_needed: false,
                                         completed: 6.years.ago)
      FactoryGirl.create_list(:study, 5, study_stage: :withdrawn_postponed,
                                         protocol_needed: false)
      FactoryGirl.create_list(:study, 5)
      expect(total_not_withdrawn_studies).to eq 10
    end
  end

  describe "#total_locations" do
    it "returns the total number of distinct locations" do
      FactoryGirl.create(:study, country_codes: %w(GB))
      FactoryGirl.create(:study, country_codes: %w(GB))
      FactoryGirl.create(:study, country_codes: %w(SM))
      FactoryGirl.create(:study, country_codes: %w(BD))
      expect(total_locations).to eq 3
    end
  end

  describe "#total_impactful_studies" do
    it "returns the total number of impactful studies" do
      studies = FactoryGirl.create_list(:study, 4)
      FactoryGirl.create(:publication, study: studies.first)
      FactoryGirl.create(:dissemination, study: studies.first)
      FactoryGirl.create(:study_impact, study: studies.first)
      FactoryGirl.create(:dissemination, study: studies.second)
      FactoryGirl.create(:study_impact, study: studies.third)
      expect(total_impactful_studies).to eq 3
    end
  end
end
