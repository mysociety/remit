class AddExemptionApprovedByToStudy < ActiveRecord::Migration
  def change
    add_column :studies, :exemption_approved_by, :text, null: true
  end
end
