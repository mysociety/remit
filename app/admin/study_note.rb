ActiveAdmin.register StudyNote do
  permit_params :notes, :study_id, :user_id

  menu priority: 3

  filter :study
  filter :user
  filter :notes
  filter :created_at

  index do
    selectable_column
    column :notes
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
