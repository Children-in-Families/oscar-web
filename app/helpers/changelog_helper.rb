module ChangelogHelper
  def changelog_type_label(changelog_type)
    case changelog_type
    when 'added'   then 'success'
    when 'fixed'   then 'warning'
    when 'updated' then 'primary'
    when 'removed' then 'danger'
    end
  end
end