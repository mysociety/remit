class AddDeliveryDelayedToStudy < ActiveRecord::Migration
  def change
    add_column :studies, :delivery_delayed, :boolean, default: false,
                                                      null: false
  end
end
