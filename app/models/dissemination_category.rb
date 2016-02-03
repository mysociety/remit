# == Schema Information
#
# Table name: dissemination_categories
#
#  id                          :integer          not null, primary key
#  name                        :text             not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  description                 :text
#  dissemination_category_type :enum             not null
#
# Indexes
#
#  index_dissemination_categories_on_name  (name) UNIQUE
#

class DisseminationCategory < ActiveRecord::Base
  OTHER_INTERNAL_CATEGORY_NAME = "Other internal".freeze
  OTHER_EXTERNAL_CATEGORY_NAME = "Other external".freeze
  OTHER_CATEGORY_NAMES = [OTHER_INTERNAL_CATEGORY_NAME,
                          OTHER_EXTERNAL_CATEGORY_NAME]
  OTHER_CATEGORY_NAMES.freeze

  enum dissemination_category_type: {
    internal: "internal",
    external: "external"
  }

  has_many :disseminations, inverse_of: :dissemination_category

  validates :name, presence: true, uniqueness: true
  validates :dissemination_category_type, presence: true
  validate :lock_other_category_names

  def lock_other_category_names
    return if !OTHER_CATEGORY_NAMES.include?(name_was) || new_record?

    message = "You cannot change the name of the #{name_was} " \
      "DisseminationCategory, it's needed for other parts of the code to " \
      "work correctly."
    errors.add(:name, message) if name_changed?
  end

  def self.other_internal_category
    DisseminationCategory.find_by_name!(OTHER_INTERNAL_CATEGORY_NAME)
  rescue ActiveRecord::RecordNotFound
    message = "A DisseminationCategory record with the name " \
      "#{OTHER_INTERNAL_CATEGORY_NAME} couldn't be found in the database. " \
      "This is essential to the proper functioning of the system. Perhaps " \
      "you changed its name, or haven't loaded in seeds.rb?"
    raise ActiveRecord::RecordNotFound, message
  end

  def self.other_external_category
    DisseminationCategory.find_by_name!(OTHER_EXTERNAL_CATEGORY_NAME)
  rescue ActiveRecord::RecordNotFound
    message = "A DisseminationCategory record with the name " \
      "#{OTHER_INTERNAL_CATEGORY_NAME} couldn't be found in the database. " \
      "This is essential to the proper functioning of the system. Perhaps " \
      "you changed its name, or haven't loaded in seeds.rb?"
    raise ActiveRecord::RecordNotFound, message
  end

  # Return a hash of categories for use in a select field, grouped by whether
  # they are internal or external
  def self.grouped_options_for_select
    internal = DisseminationCategory.where(
      dissemination_category_type: "internal")
    external = DisseminationCategory.where(
      dissemination_category_type: "external")
    {
      "Internal" => internal.map { |dc| [dc.name, dc.id] },
      "External" => external.map { |dc| [dc.name, dc.id] },
    }
  end
end
