ActiveAdmin.register StudySetting do
  permit_params :name, :description
  menu parent: "Field options"
end
