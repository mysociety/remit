FactoryGirl.define do
  factory :sent_alert, aliases: [:delayed_completing] do
    study
    user
    alert_type SentAlert::DELAYED_COMPLETING

    factory :erb_approval_expiring do
      alert_type SentAlert::APPROVAL_EXPIRING
    end

    factory :erb_response_overdue do
      alert_type SentAlert::RESPONSE_OVERDUE
    end
  end
end
