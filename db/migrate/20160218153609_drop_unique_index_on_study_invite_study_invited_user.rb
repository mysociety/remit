class DropUniqueIndexOnStudyInviteStudyInvitedUser < ActiveRecord::Migration
  def change
    remove_index :study_invites, [:study_id, :invited_user_id]
  end
end
