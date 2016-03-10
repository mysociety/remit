class CreateDeliveryUpdateStatuses < ActiveRecord::Migration
  def change
    create_table :delivery_update_statuses do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps null: false
      t.index :name, unique: true
    end
  end
end
