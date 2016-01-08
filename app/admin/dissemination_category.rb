ActiveAdmin.register DisseminationCategory do
  permit_params :name, :dissemination_category_type, :description

  menu parent: "Field options"

  form do |f|
    f.inputs "Edit Dissemination Category" do
      f.input :name
      f.input :description
      f.input :dissemination_category_type,
              as: :select,
              collection: DisseminationCategory.dissemination_category_types
    end
    f.actions
  end
end
