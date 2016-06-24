class RemoveFedBackToFieldFromDisseminations < ActiveRecord::Migration
  def change
    remove_column :disseminations, :fed_back_to_field, null: false
  end
end
