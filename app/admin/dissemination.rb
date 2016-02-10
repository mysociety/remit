ActiveAdmin.register Dissemination do
  permit_params :dissemination_category_id, :study_id, :details, :user_id,
                :fed_back_to_field, :other_dissemination_category

  menu priority: 3

  filter :study
  filter :user
  filter :created_at
  filter :dissemination_category
end
