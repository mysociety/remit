# == Schema Information
#
# Table name: delivery_update_statuses
#
#  id                         :integer          not null, primary key
#  name                       :string           not null
#  description                :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  good_medium_bad_or_neutral :enum             default("neutral"), not null
#
# Indexes
#
#  index_delivery_update_statuses_on_name  (name) UNIQUE
#

FactoryGirl.define do
  factory :delivery_update_status, aliases: [:progressing_fine] do
    name "Progressing fine"
    good_medium_bad_or_neutral "good"

    factory :not_started do
      name "Not started"
      good_medium_bad_or_neutral "neutral"
    end

    factory :minor_problems do
      name "Minor problems or delays"
      good_medium_bad_or_neutral "medium"
    end

    factory :major_problems do
      name "Major problems or delays"
      good_medium_bad_or_neutral "bad"
    end

    factory :completed do
      name "Completed"
      good_medium_bad_or_neutral "neutral"
    end
  end
end
