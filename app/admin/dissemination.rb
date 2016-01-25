ActiveAdmin.register Dissemination do
  permit_params :dissemination_category_id, :study_id, :details,
                :fed_back_to_field, :other_dissemination_category

  menu priority: 3

  filter :study
  filter :created_at
  filter :dissemination_category
end
