module ClientsHelper
  def user(user)
    if can? :manage, :all
      link_to user.name, user_path(user) if user.present?
    elsif user.present?
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

  def able_screen_link(client)
    if client.answers.any?
      link_to '', 'data-target': '#clientAnswer', 'data-toggle': :modal, type: :button do
        content_tag(:span, t('.client_able_answers'), class: 'btn btn-xs btn-warning small-btn-margin')
      end
    else
      return content_tag(:span, t('.able_screening_questions'), class: 'btn btn-xs btn-warning small-btn-margin disabled') if client.date_of_birth.blank?
      link_to able_screens_answer_submissions_client_able_screening_answers_new_path(client) do
        content_tag(:span, t('.able_screening_questions'), class: "btn btn-xs btn-warning small-btn-margin #{'disabled' if client.date_of_birth.blank?}")
      end
    end
  end

  def report_options(title, yaxis_title)
    {
      library: {
        legend: {
          verticalAlign: 'top',
          y: 30
        },
        tooltip: {
          shared: true,
          xDateFormat: '%b %Y'
        },
        title: {
          text: title
        },
        xAxis: {
          dateTimeLabelFormats: {
            month: '%b %Y'
          },
          tickmarkPlacement: 'on'
        },
        yAxis: {
          allowDecimals: false,
          title: {
            text: yaxis_title
          }
        }
      }
    }
  end

  def columns_visibility(column)
    label_column = {
      slug:                          t('datagrid.columns.clients.id'),
      code:                          t('datagrid.columns.clients.code'),
      case_type:                     t('datagrid.columns.clients.case_type'),
      age:                           t('datagrid.columns.clients.age'),
      first_name:                    t('datagrid.columns.clients.first_name'),
      last_name:                     t('datagrid.columns.clients.last_name'),
      local_first_name:              t('datagrid.columns.clients.local_first_name'),
      local_last_name:               t('datagrid.columns.clients.local_last_name'),
      gender:                        t('datagrid.columns.clients.gender'),
      date_of_birth:                 t('datagrid.columns.clients.date_of_birth'),
      birth_province_id:             t('datagrid.columns.clients.birth_province'),
      status:                        t('datagrid.columns.clients.status'),
      received_by_id:                t('datagrid.columns.clients.received_by'),
      followed_up_by_id:             t('datagrid.columns.clients.follow_up_by'),
      initial_referral_date:         t('datagrid.columns.clients.initial_referral_date'),
      referral_phone:                t('datagrid.columns.clients.referral_phone'),
      referral_source_id:            t('datagrid.columns.clients.referral_source'),
      follow_up_date:                t('datagrid.columns.clients.follow_up_date'),
      agencies_name:                 t('datagrid.columns.clients.agencies_involved'),
      province_id:                   t('datagrid.columns.clients.current_province'),
      current_address:               t('datagrid.columns.clients.current_address'),
      school_name:                   t('datagrid.columns.clients.school_name'),
      grade:                         t('datagrid.columns.clients.school_grade'),
      able_state:                    t('datagrid.columns.clients.able_state'),
      has_been_in_orphanage:         t('datagrid.columns.clients.has_been_in_orphanage'),
      has_been_in_government_care:   t('datagrid.columns.clients.has_been_in_government_care'),
      relevant_referral_information: t('datagrid.columns.clients.relevant_referral_information'),
      user_id:                       t('datagrid.columns.clients.case_worker'),
      state:                         t('datagrid.columns.clients.state'),
      family_id:                     t('datagrid.columns.clients.family_id'),
      any_assessments:               t('datagrid.columns.clients.assessments'),
      donor:                         t('datagrid.columns.clients.donor')
    }
    label_tag "#{column}_", label_column[column.to_sym]
  end

  def case_button(type)
    link_to new_client_case_path(@client, case_type: type) do
      content_tag(:span, '') do
        content_tag(:span, t(".add_#{type.downcase}_btn"), class: 'text-success')
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

  def can_read_client_progress_note?
    @client.able? && (current_user.case_worker? || current_user.able_manager? || current_user.admin? || current_user.fc_manager? || current_user.kc_manager? || current_user.strategic_overviewer?)
  end

  def disable_case_histories?
    'disabled' if current_user.able_manager?
  end
end
