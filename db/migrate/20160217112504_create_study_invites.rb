class CreateStudyInvites < ActiveRecord::Migration
  def change
    add_column :users, :invite_token, :string, index: true, unique: true

    create_table :study_invites do |t|
      t.references :study, index: true, foreign_key: true, null: false
      t.references :inviting_user, index: true, null: false
      t.references :invited_user, index: true, null: false
      t.timestamps null: false
    end

    # We can only invite a user to a study once, no matter who invites them
    add_index :study_invites, [:study_id, :invited_user_id], unique: true

    # t.references doesn't let us specify the table we want to reference to,
    # so make the foreign key separately
    add_foreign_key :study_invites, :users, column: :inviting_user_id
    add_foreign_key :study_invites, :users, column: :invited_user_id
  end
end
