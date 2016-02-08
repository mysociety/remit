class RenameCountryCodeToCountryCodesOnStudies < ActiveRecord::Migration
  def change
    rename_column :studies, :country_code, :country_codes
  end
end
