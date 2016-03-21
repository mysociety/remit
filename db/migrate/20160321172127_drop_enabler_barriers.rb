class DropEnablerBarriers < ActiveRecord::Migration
  def change
    drop_table :study_enabler_barriers
    drop_table :enabler_barriers
  end
end
