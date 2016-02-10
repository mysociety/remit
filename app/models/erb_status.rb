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
  enum good_bad_or_neutral: {
    good: "good",
    bad: "bad",
    neutral: "neutral"
  }

  has_many :studies, inverse_of: :erb_status

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :good_bad_or_neutral, presence: true
end
