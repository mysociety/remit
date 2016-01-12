# == Schema Information
#
# Table name: study_types
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_study_types_on_name  (name) UNIQUE
#

class StudyType < ActiveRecord::Base
  # The name we expect the "other" record to have in the db
  OTHER_STUDY_TYPE_NAME = "Other".freeze

  has_many :studies, inverse_of: :study_type

  validates :name, presence: true, uniqueness: true
  validates_with(
    LockedFieldValidator,
    locked_value: OTHER_STUDY_TYPE_NAME,
    attribute: :name)

  def self.other_study_type
    StudyType.find_by_name!(OTHER_STUDY_TYPE_NAME)
  rescue ActiveRecord::RecordNotFound
    message = "A StudyType record with the name #{OTHER_STUDY_TYPE_NAME} " \
      "couldn't be found in the database. This is essential to the proper " \
      "functioning of the system. Perhaps you changed its name, or haven't " \
      "loaded in seeds.rb?"
    raise ActiveRecord::RecordNotFound, message
  end
end
