class AddErbSubmittedErbApprovedToStudy < ActiveRecord::Migration
  def change
    add_column :studies, :erb_submitted, :date
    add_column :studies, :erb_approved, :date
  end
end
