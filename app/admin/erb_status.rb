ActiveAdmin.register ErbStatus do
  permit_params :name, :description, :good_bad_or_neutral
  menu parent: "Field options"

  form do |f|
    f.inputs "Edit Erb Status" do
      f.input :name, as: :string
      f.input :description, as: :string
      f.input :good_bad_or_neutral,
              as: :select,
              collection: ErbStatus.good_bad_or_neutrals
    end
    f.actions
  end
end
