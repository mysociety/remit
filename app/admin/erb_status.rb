ActiveAdmin.register ErbStatus do
  permit_params :name
  menu parent: "Field options"
end
