ActiveAdmin.register PublicationType do
  permit_params :name, :description
  menu parent: "Field options"
end
