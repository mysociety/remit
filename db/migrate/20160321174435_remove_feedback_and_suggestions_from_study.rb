class RemoveFeedbackAndSuggestionsFromStudy < ActiveRecord::Migration
  def change
    remove_column :studies, :feedback_and_suggestions
  end
end
