class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps null: false
    end

    create_table :study_collaborators do |t|
      t.belongs_to :study, index: true, null: false, foreign_key: true
      t.belongs_to :collaborator, index: true, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :study_collaborators,
                 [:study_id, :collaborator_id],
                 unique: true
  end
end
