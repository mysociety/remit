# == Schema Information
#
# Table name: collaborators
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :collaborator do
    sequence(:name) { |n| "Test Collaborator #{n}" }
  end
end
