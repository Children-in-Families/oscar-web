class UserGrid < BaseGrid

  scope do
    User.includes(:department, :province).order(:first_name, :last_name)
  end

  filter(:first_name, :string, header: -> { I18n.t('datagrid.columns.users.first_name') }) do |value, scope|
    scope.first_name_like(value)
  end

  filter(:last_name, :string, header: -> { I18n.t('datagrid.columns.users.last_name') }) do |value, scope|
    scope.last_name_like(value)
  end

  filter(:id, :integer, header: -> { I18n.t('datagrid.columns.users.id') })

  filter(:gender, :enum, select: :gender_list,  header: -> { I18n.t('datagrid.columns.users.gender') }) do |value, scope|
    scope.where(gender: value.downcase)
  end

  def gender_list
    User::GENDER_OPTIONS.map{ |value| [I18n.t("users.gender_list.#{value.gsub('other', 'other_gender')}"), value] }
  end

  filter(:mobile, :string,  header: -> { I18n.t('datagrid.columns.users.mobile') }) do |value, scope|
    scope.mobile_like(value)
  end

  filter(:email, :string,  header: -> { I18n.t('datagrid.columns.users.email') }) do |value, scope|
    scope.email_like(value)
  end

  filter(:job_title, :enum, select: :job_title_options,  header: -> { I18n.t('datagrid.columns.users.job_title') })

  def job_title_options
    User.job_title_are
  end

  filter(:date_of_birth, :date, range: true, header: -> { I18n.t('datagrid.columns.users.date_of_birth') })

  filter(:start_date, :date, range: true,  header: -> { I18n.t('datagrid.columns.users.start_date') })

  filter(:department, :enum, select: :department_options, header: -> { I18n.t('datagrid.columns.users.department') })
  def department_options
    User.department_are
  end

  filter(:roles, :enum, select: User::ROLES.map{|val| [val.titleize, val]},  header: -> { I18n.t('datagrid.columns.users.roles') })

  filter(:province_id, :enum, select: :province_options,  header: -> { I18n.t('datagrid.columns.users.province') })
  def province_options
    User.province_are
  end

  filter(:manager_id, :enum, select: :managers, header: -> { I18n.t('datagrid.columns.users.manager') })

  def managers
    User.managers.map{ |u| [u.name, u.id] }
  end

  column(:id, header: -> { I18n.t('datagrid.columns.users.id') })

  column(:name, html: true, order: 'LOWER(users.first_name), LOWER(users.last_name)',  header: -> { I18n.t('datagrid.columns.users.name') }) do |object|
    link_to object.name, user_path(object)
  end

  column(:first_name, header: -> { I18n.t('datagrid.columns.users.first_name') }, html: false)
  column(:last_name, header: -> { I18n.t('datagrid.columns.users.last_name') }, html: false)

  date_column(:date_of_birth, html: true, header: -> { I18n.t('datagrid.columns.users.date_of_birth') })

  column(:date_of_birth, html: false, header: -> { I18n.t('datagrid.columns.users.date_of_birth') }) do |object|
    object.date_of_birth.present? ? object.date_of_birth : ''
  end

  column(:gender, header: -> { I18n.t('datagrid.columns.users.gender') }) do |object|
    object.gender.present? ? I18n.t("enumerize.defaults.gender.#{object.gender.parameterize.underscore&.gsub('other', 'other_gender')}") : ''
  end

  column(:mobile, header: -> { I18n.t('datagrid.columns.users.mobile') })

  column(:email, header: -> { I18n.t('datagrid.columns.users.email') }) do |object|
    format(object.email) do |object_email|
      mail_to object_email
    end
  end

  column(:job_title, header: -> { I18n.t('datagrid.columns.users.job_title') })

  column(:department, order: 'departments.name', header: -> { I18n.t('datagrid.columns.users.department') }) do |object|
    object.department.try(:name)
  end

  date_column(:start_date, html: true, header: -> { I18n.t('datagrid.columns.users.start_date') })
  column(:start_date, html: false, header: -> { I18n.t('datagrid.columns.users.start_date') }) do |object|
    object.start_date.present? ? object.start_date : ''
  end

  column(:province, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.users.province') }) do |object|
    object.province.try(:name)
  end

  column(:roles, header: -> { I18n.t('datagrid.columns.users.roles') }) do |object|
    object.roles.titleize
  end

  column(:manager_id, header: -> { I18n.t('datagrid.columns.users.manager') }) do |object|
    User.find_by(id: object.manager_id).try(:name)
  end

  column(:manage, header: -> { I18n.t('datagrid.columns.users.manage') }, html: true, class: 'text-center') do |object|
    render partial: 'users/actions', locals: { object: object }
  end

  column(:changelog, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.users.changelogs') }) do |object|
    link_to t('datagrid.columns.users.view'), user_version_path(object)
  end
end
