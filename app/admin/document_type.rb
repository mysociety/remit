ActiveAdmin.register DocumentType do
  permit_params :name, :description
  menu parent: "Field options"
end
