class CreateDeliveryUpdateInvites < ActiveRecord::Migration
  def change
    create_table :delivery_update_invites do |t|
      t.references :study, index: true, foreign_key: true, null: false
      t.references :invited_user, index: true, null: false
      t.references :inviting_user, index: true, null: false
      t.references :delivery_update, index: true, foreign_key: true

      t.timestamps null: false
    end

    # t.references doesn't let us specify the table we want to reference to,
    # so make the foreign key separately
    add_foreign_key :delivery_update_invites, :users, column: :inviting_user_id
    add_foreign_key :delivery_update_invites, :users, column: :invited_user_id
  end
end
