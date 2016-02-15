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

class SentAlert < ActiveRecord::Base
  DELAYED_COMPLETING = "delayed_completion".freeze
  APPROVAL_EXPIRING = "erb_approval_expiring".freeze
  RESPONSE_OVERDUE = "erb_response_overdue".freeze
  ALERT_TYPES = [
    DELAYED_COMPLETING,
    APPROVAL_EXPIRING,
    RESPONSE_OVERDUE
  ].freeze

  belongs_to :study
  belongs_to :user

  validates :study, presence: true
  validates :user, presence: true
  validates :alert_type, presence: true, inclusion: { in: ALERT_TYPES }
end
