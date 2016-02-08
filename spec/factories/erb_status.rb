FactoryGirl.define do
  factory :erb_status, aliases: [:exempt_status] do
    name "Exempt"

    factory :in_draft do
      name "In draft"
    end

    factory :submitted do
      name "Submitted"
    end

    factory :reject do
      name "Reject"
    end

    factory :rereview do
      name "Re-review"
    end

    factory :accept do
      name "Accept"
    end
  end
end
