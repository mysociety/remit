FactoryGirl.define do
  factory :erb_status, aliases: [:exempt_status] do
    name "Exempt"
    description "Was marked as exempt from ERB"
    good_bad_or_neutral "good"

    factory :in_draft do
      name "In draft"
      description "Protocol is in draft"
      good_bad_or_neutral "neutral"
    end

    factory :submitted do
      name "Submitted"
      description "Protocol submitted to ERB"
      good_bad_or_neutral "neutral"
    end

    factory :reject do
      name "Reject"
      description "Protocol was rejected by ERB"
      good_bad_or_neutral "bad"
    end

    factory :rereview do
      name "Re-review"
      description "Protocol re-submitted to ERB"
      good_bad_or_neutral "neutral"
    end

    factory :accept do
      name "Accept"
      description "Protocol accepted by ERB"
      good_bad_or_neutral "good"
    end
  end
end
