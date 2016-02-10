ActiveAdmin.register StudyImpact do
  permit_params :impact_type_id, :study_id, :description, :user_id

  menu priority: 4

  filter :study
  filter :user
  filter :impact_type_id
  filter :created_at
end
