class CreateSentAlerts < ActiveRecord::Migration
  def change
    create_table :sent_alerts do |t|
      t.references :study, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.text :alert_type, index: true, null: false

      t.timestamps null: false
    end

    add_index :sent_alerts, [:study_id, :user_id, :alert_type], unique: true
  end
end
