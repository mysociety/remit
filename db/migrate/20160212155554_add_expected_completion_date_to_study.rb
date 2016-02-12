class AddExpectedCompletionDateToStudy < ActiveRecord::Migration
  def change
    add_column :studies, :expected_completion_date, :date
  end
end
