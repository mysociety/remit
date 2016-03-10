class CreateDeliveryUpdates < ActiveRecord::Migration
  def change
    create_table :delivery_updates do |t|
      t.references :study, index: true, foreign_key: true, null: false
      t.references :data_analysis_status, index: true,
                                          null: false
      t.references :data_collection_status, index: true,
                                            null: false
      t.references :interpretation_and_write_up_status, index: true,
                                                        null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.text :comments

      t.timestamps null: false
    end

    add_foreign_key(
      :delivery_updates,
      :delivery_update_statuses,
      column: :data_analysis_status_id)
    add_foreign_key(
      :delivery_updates,
      :delivery_update_statuses,
      column: :data_collection_status_id)
    add_foreign_key(
      :delivery_updates,
      :delivery_update_statuses,
      column: :interpretation_and_write_up_status_id)
  end
end
