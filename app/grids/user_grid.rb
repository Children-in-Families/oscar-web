class UserGrid
  include Datagrid

  scope do
    User.includes(:department).order(:first_name, :last_name)
  end

  filter(:first_name, :string, header: -> { I18n.t('datagrid.columns.users.first_name') }) do |value, scope|
    scope.first_name_like(value)
  end

  filter(:last_name, :string, header: -> { I18n.t('datagrid.columns.users.last_name') }) do |value, scope|
    scope.last_name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.users.id') })

  filter(:mobile, :string,  header: -> { I18n.t('datagrid.columns.users.mobile') }) do |value, scope|
    scope.mobile_like(value)
  end

  filter(:email, :string,  header: -> { I18n.t('datagrid.columns.users.email') }) do |value, scope|
    scope.email_like(value)
  end

  filter(:job_title, :enum, select: :job_title_options,  header: -> { I18n.t('datagrid.columns.users.job_title') })
  def job_title_options
    scope.job_title_is
  end

  filter(:date_of_birth, :date, range: true, header: -> { I18n.t('datagrid.columns.users.date_of_birth') })

  filter(:start_date, :date, range: true,  header: -> { I18n.t('datagrid.columns.users.start_date') })

  filter(:department, :enum, select: :department_options, header: -> { I18n.t('datagrid.columns.users.department') })
  def department_options
    scope.department_is
  end

  filter(:roles, :enum, select: :role_options,  header: -> { I18n.t('datagrid.columns.users.roles') })
  def role_options
    scope.map { |u| [u.roles.titleize, u.roles] }.uniq
  end

  filter(:province_id, :enum, select: :province_options,  header: -> { I18n.t('datagrid.columns.users.province') })
  def province_options
    scope.province_is
  end

  column(:id, header: -> { I18n.t('datagrid.columns.users.id') })

  column(:name, html: true, order: 'LOWER(users.first_name), LOWER(users.last_name)',  header: -> { I18n.t('datagrid.columns.users.name') }) do |object|
    link_to object.name, user_path(object)
  end

  column(:first_name, header: -> { I18n.t('datagrid.columns.users.first_name') }, html: false)
  column(:last_name, header: -> { I18n.t('datagrid.columns.users.last_name') }, html: false)

  column(:date_of_birth, header: -> { I18n.t('datagrid.columns.users.date_of_birth') }, html: false)

  column(:mobile, header: -> { I18n.t('datagrid.columns.users.mobile') }) do |object|
    object.mobile.phony_formatted(normalize: :KH, format: :international) if object.mobile
  end

  column(:email, header: -> { I18n.t('datagrid.columns.users.email') }) do |object|
    format(object.email) do |object_email|
      mail_to object_email
    end
  end

  column(:job_title, header: -> { I18n.t('datagrid.columns.users.job_title') })

  column(:department, order: 'departments.name', header: -> { I18n.t('datagrid.columns.users.department') }) do |object|
    object.department.name if object.department
  end

  column(:start_date, header: -> { I18n.t('datagrid.columns.users.start_date') }, html: false)

  column(:province, header: -> { I18n.t('datagrid.columns.users.province') }, html: false) do |object|
    object.province.name if object.province
  end

  column(:roles, header: -> { I18n.t('datagrid.columns.users.roles') }) do |object|
    object.roles.titleize
  end

  column(:manage, header: -> { I18n.t('datagrid.columns.users.manage') }, html: true, class: 'text-center') do |object|
    render partial: 'users/actions', locals: { object: object }
  end

  column(:modification, html: true, class: 'text-center', header: I18n.t('datagrid.columns.users.modification')) do |object|
    link_to 'View', user_version_path(object)
  end
end
