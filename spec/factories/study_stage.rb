FactoryGirl.define do
  factory :study_stage, aliases: [:concept_stage] do
    name "Concept"

    factory :protocol_stage do
      name "Protocol & ERB"
    end

    factory :delivery_stage do
      name "Delivery"
    end

    factory :output_stage do
      name "Output"
    end

    factory :completion_stage do
      name "Completion"
    end

    factory :withdrawn_postponed_stage do
      name "Withdrawn/Postponed"
    end
  end
end
