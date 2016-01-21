class CreateStudyEnablerBarriers < ActiveRecord::Migration
  def change
    # Create a new explicit join table for StudyEnablerBarriers
    create_table :study_enabler_barriers do |t|
      t.belongs_to :study, index: true, null: false, foreign_key: true
      t.belongs_to :enabler_barrier, index: true,
                                     null: false,
                                     foreign_key: true
      t.text :description
      t.timestamps null: false
    end

    # Drop the existing anonymous join table Rails created for us before
    drop_table :enabler_barriers_studies do |t|
      t.integer :enabler_barrier_id, index: true, null: false
      t.integer :study_id, index: true, null: false
    end
  end
end
