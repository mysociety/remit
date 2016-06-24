# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: disseminations
#
#  id                           :integer          not null, primary key
#  dissemination_category_id    :integer          not null
#  study_id                     :integer          not null
#  details                      :text             not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  other_dissemination_category :text
#  user_id                      :integer
#
# Indexes
#
#  index_disseminations_on_dissemination_category_id  (dissemination_category_id)
#  index_disseminations_on_study_id                   (study_id)
#  index_disseminations_on_user_id                    (user_id)
#

class Dissemination < ActiveRecord::Base
  include StudyActivityTrackable

  belongs_to :dissemination_category, inverse_of: :disseminations
  belongs_to :study, inverse_of: :disseminations
  belongs_to :user, inverse_of: :disseminations

  validates :study, presence: true
  validates :dissemination_category, presence: true
  validates :details, presence: true
  validate :other_dissemination_category_is_set_when_category_is_other

  def other_dissemination_category_is_set_when_category_is_other
    other_categories = [
      DisseminationCategory.other_internal_category,
      DisseminationCategory.other_external_category,
    ]
    if other_categories.include?(dissemination_category) && \
       other_dissemination_category.blank?

      message = "You must describe the dissemination category if you " \
        "choose \"#{dissemination_category.name}\""
      errors.add(:other_dissemination_category, message)
    end
  end
end
