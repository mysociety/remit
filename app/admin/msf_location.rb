ActiveAdmin.register MsfLocation do
  permit_params :name, :description
  menu parent: "Field options"
end
