FactoryGirl.define do
  factory :study_enabler_barrier do
    study
    enabler_barrier
    sequence(:description) { |n| "Test enabler/barrier #{n}" }

    after(:build) do |eb|
      if eb.enabler_barrier.nil?
        name = "Enablers/barriers to study delivery"
        delivery_barrier = EnablerBarrier.find_by_name(name)
        eb.enabler_barrier = delivery_barrier || create(:delivery_barrier)
      end
    end
  end
end
