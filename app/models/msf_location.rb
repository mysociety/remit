# == Schema Information
#
# Table name: msf_locations
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_msf_locations_on_name  (name) UNIQUE
#

class MsfLocation < ActiveRecord::Base
  EXTERNAL_LOCATION_NAME = "External".freeze

  has_many :users, inverse_of: :msf_location

  validates :name, presence: true, uniqueness: true
  validates_with(
    LockedFieldValidator,
    locked_value: EXTERNAL_LOCATION_NAME,
    attribute: :name)

  def self.external_location
    MsfLocation.find_by_name!(EXTERNAL_LOCATION_NAME)
  rescue ActiveRecord::RecordNotFound
    message = "An MsfLocation record with the name #{EXTERNAL_LOCATION_NAME} " \
      "couldn't be found in the database. This is essential to the proper " \
      "functioning of the system. Perhaps you changed its name, or haven't " \
      "loaded in seeds.rb?"
    raise ActiveRecord::RecordNotFound, message
  end
end
