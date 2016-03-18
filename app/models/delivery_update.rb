# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: delivery_updates
#
#  id                                    :integer          not null, primary key
#  study_id                              :integer          not null
#  data_analysis_status_id               :integer          not null
#  data_collection_status_id             :integer          not null
#  interpretation_and_write_up_status_id :integer          not null
#  user_id                               :integer          not null
#  comments                              :text
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#
# Indexes
#
#  index_delivery_updates_on_data_analysis_status_id                (data_analysis_status_id)
#  index_delivery_updates_on_data_collection_status_id              (data_collection_status_id)
#  index_delivery_updates_on_interpretation_and_write_up_status_id  (interpretation_and_write_up_status_id)
#  index_delivery_updates_on_study_id                               (study_id)
#  index_delivery_updates_on_user_id                                (user_id)
#

class DeliveryUpdate < ActiveRecord::Base
  belongs_to :study, inverse_of: :delivery_updates
  belongs_to :data_analysis_status, class_name: :DeliveryUpdateStatus
  belongs_to :data_collection_status, class_name: :DeliveryUpdateStatus
  belongs_to(
    :interpretation_and_write_up_status,
    class_name: :DeliveryUpdateStatus
  )
  belongs_to :user, inverse_of: :delivery_updates
  has_many :delivery_update_invites, inverse_of: :delivery_update

  validates :study, presence: true
  validates :data_analysis_status, presence: true
  validates :data_collection_status, presence: true
  validates :interpretation_and_write_up_status, presence: true
  validates :user, presence: true

  def to_s
    "#{created_at.to_formatted_s(:medium_ordinal)} " \
    "Update on: #{study.reference_number}"
  end

  def delayed?
    delayed_statuses = DeliveryUpdateStatus.delayed_statuses
    delayed_statuses.include?(data_analysis_status) || \
      delayed_statuses.include?(data_collection_status) || \
      delayed_statuses.include?(interpretation_and_write_up_status)
  end
end
