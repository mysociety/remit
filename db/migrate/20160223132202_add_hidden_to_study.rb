class AddHiddenToStudy < ActiveRecord::Migration
  def change
    add_column :studies, :hidden, :boolean, default: false, index: true
  end
end
