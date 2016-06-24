ActiveAdmin.register Dissemination do
  permit_params :dissemination_category_id, :study_id, :details, :user_id,
                :other_dissemination_category

  menu priority: 3

  filter :study
  filter :user
  filter :created_at
  filter :dissemination_category

  index do
    selectable_column
    column :dissemination_category
    column "Study Ref" do |instance|
      instance.study.reference_number
    end
    column "Study Title" do |instance|
      instance.study.title
    end
    column :user
    column :created_at
    actions
  end
end
