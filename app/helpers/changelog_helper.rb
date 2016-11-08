module ChangelogHelper
  def changelog_type_label(changelog_type)
    case changelog_type
    when 'added'   then 'primary'
    when 'fixed'   then 'warning'
    when 'updated' then 'success'
    when 'removed' then 'danger'
    end
  end
end
