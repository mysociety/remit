ActiveAdmin.register DeliveryUpdate do
  permit_params :study_id, :data_analysis_status_id,
                :data_collection_status_id,
                :interpretation_and_write_up_status_id, :user_id, :comments

  menu parent: "Delivery updates"

  filter :study
  filter :user
  filter :created

  index do
    selectable_column
    column "Study Ref" do |instance|
      instance.study.reference_number
    end
    column "Study Title" do |instance|
      instance.study.title
    end
    column :user
    column :data_collection_status
    column :data_analysis_status
    column :interpretation_and_write_up_status
    column :created_at
    actions
  end
end
