class AddDocumentToDocument < ActiveRecord::Migration
  def change
    add_attachment :documents, :document
  end
end
