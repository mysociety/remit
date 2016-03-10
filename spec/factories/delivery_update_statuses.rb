FactoryGirl.define do
  factory :delivery_update_status, aliases: [:progressing_fine] do
    name "Progressing fine"
  end

  factory :not_started do
    name "Not started"
  end

  factory :minor_problems do
    name "Minor problems or delays"
  end

  factory :major_problems do
    name "Major problems or delays"
  end

  factory :completed do
    name "Completed"
  end
end
