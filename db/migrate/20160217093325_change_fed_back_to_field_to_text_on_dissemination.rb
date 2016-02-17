class ChangeFedBackToFieldToTextOnDissemination < ActiveRecord::Migration
  def change
    change_column :disseminations, :fed_back_to_field, :text
  end
end
