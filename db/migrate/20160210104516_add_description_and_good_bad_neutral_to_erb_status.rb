class AddDescriptionAndGoodBadNeutralToErbStatus < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE good_bad_neutral
      AS ENUM ('good', 'bad', 'neutral');
    SQL

    add_column :erb_statuses, :description, :text, null: false
    add_column(
      :erb_statuses,
      :good_bad_or_neutral,
      :good_bad_neutral,
      null: false,
      default: "neutral")
  end

  def down
    remove_column :erb_statuses, :description
    remove_column :erb_statuses, :good_bad_or_neutral
    execute "DROP TYPE good_bad_neutral;"
  end
end
