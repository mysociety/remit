class MakeStudyEnablerBarrierDescriptionNotNull < ActiveRecord::Migration
  def change
    change_column_null :study_enabler_barriers, :description, false
  end
end
