# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: sent_alerts
#
#  id         :integer          not null, primary key
#  study_id   :integer          not null
#  user_id    :integer          not null
#  alert_type :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sent_alerts_on_alert_type                           (alert_type)
#  index_sent_alerts_on_study_id                             (study_id)
#  index_sent_alerts_on_study_id_and_user_id_and_alert_type  (study_id,user_id,alert_type) UNIQUE
#  index_sent_alerts_on_user_id                              (user_id)
#
# rubocop:enable Metrics/LineLength

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
