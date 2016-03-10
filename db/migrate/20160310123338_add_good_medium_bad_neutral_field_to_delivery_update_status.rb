# rubocop:disable Metrics/LineLength
class AddGoodMediumBadNeutralFieldToDeliveryUpdateStatus < ActiveRecord::Migration
  # rubocop:enable Metrics/LineLength
  def up
    execute <<-SQL
      CREATE TYPE good_medium_bad_neutral
      AS ENUM ('good', 'medium', 'bad', 'neutral');
    SQL

    add_column(
      :delivery_update_statuses,
      :good_medium_bad_or_neutral,
      :good_medium_bad_neutral,
      null: false,
      default: "neutral")
  end

  def down
    remove_column :delivery_update_statuses, :good_medium_bad_or_neutral
    execute "DROP TYPE good_medium_bad_neutral;"
  end
end
