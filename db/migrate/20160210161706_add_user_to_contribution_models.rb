class AddUserToContributionModels < ActiveRecord::Migration
  def change
    add_reference :documents, :user, index: true, foreign_key: true
    add_reference :publications, :user, index: true, foreign_key: true
    add_reference :disseminations, :user, index: true, foreign_key: true
    add_reference :study_impacts, :user, index: true, foreign_key: true
    add_reference :study_notes, :user, index: true, foreign_key: true
    add_reference :study_enabler_barriers, :user, index: true, foreign_key: true
  end
end
