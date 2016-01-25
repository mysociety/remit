ActiveAdmin.register StudyImpact do
  permit_params :impact_type_id, :study_id, :description

  menu priority: 4

  filter :study
  filter :impact_type_id
  filter :created_at
end
