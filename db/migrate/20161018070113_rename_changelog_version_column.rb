class RenameChangelogVersionColumn < ActiveRecord::Migration
  def change
    rename_column :changelogs, :version, :change_version
  end
end
