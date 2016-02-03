class AllowConceptPaperDateNullOnStudy < ActiveRecord::Migration
  def change
    change_column_null :studies, :concept_paper_date, true
  end
end
