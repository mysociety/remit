class AddRelatedContentToActivity < ActiveRecord::Migration
  def change
    add_reference :activities, :related_content, index: true, polymorphic: true
  end
end
