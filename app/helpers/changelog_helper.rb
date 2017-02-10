module ChangelogHelper
  def changelog_type_label(changelog_type)
    type = {
      added: 'primary',
      fixed: 'warning',
      updated: 'success',
      removed: 'danger'
    }
    type[changelog_type.to_sym]
  end
end
