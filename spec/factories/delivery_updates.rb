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

FactoryGirl.define do
  factory :delivery_update do
    study
    user
    comments "Test delivery update"

    after(:build) do |d|
      if d.data_analysis_status.nil?
        progressing_fine = DeliveryUpdateStatus.find_by_name(
          "Progressing fine"
        )
        if progressing_fine
          d.data_analysis_status = progressing_fine
        else
          d.data_analysis_status = create(:progressing_fine)
        end
      end

      if d.data_collection_status.nil?
        progressing_fine = DeliveryUpdateStatus.find_by_name(
          "Progressing fine"
        )
        if progressing_fine
          d.data_collection_status = progressing_fine
        else
          d.data_collection_status = create(:progressing_fine)
        end
      end

      if d.interpretation_and_write_up_status.nil?
        progressing_fine = DeliveryUpdateStatus.find_by_name(
          "Progressing fine"
        )
        if progressing_fine
          d.interpretation_and_write_up_status = progressing_fine
        else
          d.interpretation_and_write_up_status = create(:progressing_fine)
        end
      end
    end
  end
end
