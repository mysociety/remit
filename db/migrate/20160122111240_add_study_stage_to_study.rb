class AddStudyStageToStudy < ActiveRecord::Migration
  def up
    remove_column :studies, :study_stage_id
    drop_table :study_stages
    execute <<-SQL
      CREATE TYPE study_stage
      AS ENUM ('concept', 'protocol_erb', 'delivery', 'output', 'completion', 'withdrawn_postponed');
    SQL
    add_column :studies, :study_stage, :study_stage, index: true,
                                                     null: false,
                                                     default: "concept"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
