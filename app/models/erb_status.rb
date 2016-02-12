# == Schema Information
#
# Table name: erb_statuses
#
#  id                  :integer          not null, primary key
#  name                :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  description         :text             not null
#  good_bad_or_neutral :enum             default("neutral"), not null
#
# Indexes
#
#  index_erb_statuses_on_name  (name) UNIQUE
#

class ErbStatus < ActiveRecord::Base
  SUBMITTED_ERB_STATUS = "Submitted".freeze

  enum good_bad_or_neutral: {
    good: "good",
    bad: "bad",
    neutral: "neutral"
  }

  has_many :studies, inverse_of: :erb_status

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :good_bad_or_neutral, presence: true
  validates_with(
    LockedFieldValidator,
    locked_value: SUBMITTED_ERB_STATUS,
    attribute: :name)

  # Return the special "submitted" erb status, which we use to trigger things
  # like alerts.
  def self.submitted_status
    ErbStatus.find_by_name!(SUBMITTED_ERB_STATUS)
  rescue ActiveRecord::RecordNotFound
    message = "An ErbStatus record with the name #{SUBMITTED_ERB_STATUS} " \
      "couldn't be found in the database. This is essential to the proper " \
      "functioning of the system. Perhaps you changed its name, or haven't " \
      "loaded in seeds.rb?"
    raise ActiveRecord::RecordNotFound, message
  end
end
