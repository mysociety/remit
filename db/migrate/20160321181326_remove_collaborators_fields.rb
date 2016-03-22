class RemoveCollaboratorsFields < ActiveRecord::Migration
  def change
    remove_column :studies, :local_collaborators
    remove_column :studies, :international_collaborators
  end
end
