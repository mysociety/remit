class AddAmendmentsSentToErbToStudy < ActiveRecord::Migration
  def change
    add_column :studies, :amendments_sent_to_erb, :boolean, default: false
  end
end
