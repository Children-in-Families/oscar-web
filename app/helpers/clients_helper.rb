module ClientsHelper
  def user(user)
    if can? :manage, :all
      link_to user.name, user_path(user)
    else
      user.name
    end
  end

  def partner(partner)
    if can? :manage, :all
      link_to partner.name, partner_path(partner)
    else
      partner.name
    end
  end

  def family(family)
    if can? :manage, :all
      link_to family.name, family_path(family)
    else
      family.name
    end
  end

  def columns_visibility(column)
    label_tag "#{column}_",
      case column
      when :slug                          then t('datagrid.columns.clients.id')
      when :code                          then t('datagrid.columns.clients.code')
      when :case_type                     then t('datagrid.columns.clients.case_type')
      when :age                           then t('datagrid.columns.clients.age')
      when :name                          then t('datagrid.columns.clients.name')
      when :gender                        then t('datagrid.columns.clients.gender')
      when :date_of_birth                 then t('datagrid.columns.clients.date_of_birth')
      when :birth_province_id             then t('datagrid.columns.clients.birth_province')
      when :status                        then t('datagrid.columns.clients.status')
      when :received_by_id                then t('datagrid.columns.clients.received_by')
      when :followed_up_by_id             then t('datagrid.columns.clients.follow_up_by')
      when :initial_referral_date         then t('datagrid.columns.clients.initial_referral_date')
      when :referral_phone                then t('datagrid.columns.clients.referral_phone')
      when :referral_source_id            then t('datagrid.columns.clients.referral_source')
      when :follow_up_date                then t('datagrid.columns.clients.follow_up_date')
      when :agencies_name                 then t('datagrid.columns.clients.agencies_involved')
      when :province_id                   then t('datagrid.columns.clients.current_province')
      when :current_address               then t('datagrid.columns.clients.current_address')
      when :school_name                   then t('datagrid.columns.clients.school_name')
      when :grade                         then t('datagrid.columns.clients.school_grade')
      when :able                          then t('datagrid.columns.clients.able')
      when :has_been_in_orphanage         then t('datagrid.columns.clients.has_been_in_orphanage')
      when :has_been_in_government_care   then t('datagrid.columns.clients.has_been_in_government_care')
      when :relevant_referral_information then t('datagrid.columns.clients.relevant_referral_information')
      when :user_id                       then t('datagrid.columns.clients.case_worker')
      when :state                         then t('datagrid.columns.clients.state')
      when :family_id                     then t('datagrid.columns.clients.family_id')
      when :any_assessments               then t('datagrid.columns.clients.assessments')
      end
  end

  def case_button(type)
    link_to new_client_case_path(@client, case_type: type) do
      content_tag(:div, '', class: 'col-xs-10 col-xs-offset-1 btn btn-success pushing-bottom') do
        content_tag(:h4, t(".add_#{type.downcase}_btn"))
      end
    end
  end

  def ec_manageable
    current_user.admin? || current_user.case_worker? || current_user.ec_manager?
  end

  def fc_manageable
    current_user.admin? || current_user.case_worker? || current_user.fc_manager?
  end

  def kc_manageable
    current_user.admin? || current_user.case_worker? || current_user.kc_manager?
  end

  def can_manage_client_progress_note?
    @client.able? && (current_user.case_worker? || current_user.able_manager? || current_user.admin?)
  end
end
