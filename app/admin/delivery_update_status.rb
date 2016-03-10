ActiveAdmin.register DeliveryUpdateStatus do
  permit_params :name, :good_medium_bad_or_neutral, :description

  menu parent: "Field options"

  form do |f|
    f.inputs "Edit Delivery Update Status" do
      f.input :name
      f.input :good_medium_bad_or_neutral,
              as: :select,
              collection: DeliveryUpdateStatus.good_medium_bad_or_neutrals
      f.input :description
    end
    f.actions
  end
end
