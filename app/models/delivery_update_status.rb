# == Schema Information
#
# Table name: delivery_update_statuses
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_delivery_update_statuses_on_name  (name) UNIQUE
#

class DeliveryUpdateStatus < ActiveRecord::Base
  has_many(:data_analysis_delivery_updates,
           inverse_of: :data_analysis_status,
           class_name: DeliveryUpdate)
  has_many(:data_collection_delivery_updates,
           inverse_of: :data_collection_status,
           class_name: DeliveryUpdate)
  has_many(:interpretation_and_write_up_delivery_updates,
           inverse_of: :interpretation_and_write_up_status,
           class_name: DeliveryUpdate)

  validates :name, presence: true, uniqueness: true
end
