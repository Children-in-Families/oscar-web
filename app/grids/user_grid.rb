class UserGrid
  include Datagrid

  scope do
    User.includes(:department).order(:first_name, :last_name)
  end

  filter(:first_name, :string) do |value, scope|
    scope.first_name_like(value)
  end

  filter(:last_name, :string) do |value, scope|
    scope.last_name_like(value)
  end

  filter(:date_of_birth, :date, range: true)

  filter(:start_date, :date, range: true)

  filter(:mobile, :string) do |value, scope|
    scope.mobile_like(value)
  end

  filter(:email, :string) do |value, scope|
    scope.email_like(value)
  end

  filter(:job_title, :enum, select: :job_title_options)
  def job_title_options
    scope.job_title_is
  end

  filter(:department, :enum, select: :department_options)
  def department_options
    scope.department_is
  end

  filter(:roles, :enum, header: 'Role', select: :role_options)
  def role_options
     scope.map{ |u| [u.roles.titleize, u.roles] }.uniq
  end

  filter(:province_id, :enum, select: :province_options)
  def province_options
    scope.province_is
  end

  column(:name, html: true, order: 'users.first_name, users.last_name') do |object|
    link_to object.name, user_path(object)
  end

  column(:first_name, header: 'First Name', html: false)
  column(:last_name, header: 'Last Name', html: false)

  column(:date_of_birth, header: 'Date Of Birth', html: false)

  column(:mobile) do |object|
    object.mobile.phony_formatted(normalize: :KH, format: :international) if object.mobile
  end

  column(:email) do |object|
    format(object.email) do |object_email|
     mail_to object_email
    end
  end

  column(:job_title, header: 'Job Title')

  column(:department, order: 'departments.name') do |object|
    object.department.name if object.department
  end

  column(:start_date, header: 'Start Date', html: false)

  column(:province, header: 'Province', html: false) do |object|
    object.province.name if object.province
  end

  column(:roles, header: 'Role') do |object|
    object.roles.titleize
  end

  column(:manage, html: true, class: 'text-center') do |object|
    if current_user.admin?
      render partial: 'users/actions', locals: { object: object }
    end
  end

end