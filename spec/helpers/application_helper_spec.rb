require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#study_timeline" do
    let(:base_timeline) do
      {
        concept: { label: "Concept", state: "todo" },
        protocol_erb: { label: "Protocol & ERB", state: "todo" },
        delivery: { label: "Delivery", state: "todo" },
        output: { label: "Output", state: "todo" },
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
        let(:study) { FactoryGirl.create(:study, study_stage: "protocol_erb") }

        it "returns a timeline with multiple entries" do
          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when the study is in the completion stage" do
        let(:study) { FactoryGirl.create(:study, study_stage: "completion") }

        it "returns a timeline with multiple entries" do
          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          expected_timeline[:output][:state] = "done"
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
          study.save!
          study.study_stage = "delivery"
          study.save!
          study.study_stage = "output"
          study.save!
          study.study_stage = "completion"
          study.save!

          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          expected_timeline[:output][:state] = "done"
          expected_timeline[:completion][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when a study has skipped a stage" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with multiple entries" do
          study.study_stage = "protocol_erb"
          study.save!
          study.study_stage = "delivery"
          study.save!
          study.study_stage = "completion"
          study.save!

          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          # We expect the helper to fill this in for us anyway
          expected_timeline[:output][:state] = "done"
          expected_timeline[:completion][:state] = "doing"
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when a study is in the withdrawn stage" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with entries only for completed stages" do
          study.study_stage = "protocol_erb"
          study.save!
          study.study_stage = "delivery"
          study.save!
          study.study_stage = "withdrawn_postponed"
          study.save!

          expected_timeline = base_timeline
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          # We expect the helper to delete these next two
          expected_timeline.delete(:output)
          expected_timeline.delete(:completion)
          expected_timeline[:withdrawn_postponed] = {
            label: "Withdrawn or Postponed",
            state: "doing"
          }
          expect(study_timeline(study)).to eq expected_timeline
        end
      end

      context "when a study has skipped a stage and then been withdrawn" do
        let(:study) { FactoryGirl.create(:study) }

        it "returns a timeline with multiple entries" do
          study.study_stage = "delivery"
          study.save!
          study.study_stage = "withdrawn_postponed"
          study.save!

          expected_timeline = base_timeline
          # The helper should complete these
          expected_timeline[:concept][:state] = "done"
          expected_timeline[:protocol_erb][:state] = "done"
          expected_timeline[:delivery][:state] = "done"
          # We expect the helper to delete these
          expected_timeline.delete(:output)
          expected_timeline.delete(:completion)
          # This should be the final state
          expected_timeline[:withdrawn_postponed] = {
            label: "Withdrawn or Postponed",
            state: "doing"
          }
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
end
