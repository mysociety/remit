FactoryGirl.define do
  factory :study_setting, aliases: [:stable_setting] do
    name "Stable"

    factory :unstable do
      name "Unstable"
    end

    factory :emergency do
      name "Emergency"
    end
  end
end
