module PartnersHelper
  def columns_partners_visibility(column)
    label_column = {
      name:                                     t('datagrid.columns.partners.name'),
      id:                                       t('datagrid.columns.partners.id'),
      contact_person_name:                      t('datagrid.columns.partners.contact_name'),
      contact_person_email:                     t('datagrid.columns.partners.contact_email'),
      contact_person_mobile:                    t('datagrid.columns.partners.contact_mobile'),
      address:                                  t('datagrid.columns.partners.address'),
      organisation_type:                        t('datagrid.columns.partners.organisation_type'),
      affiliation:                              t('datagrid.columns.partners.affiliation'),
      province_id:                              t('datagrid.columns.partners.province'),
      engagement:                               t('datagrid.columns.partners.engagement'),
      background:                               t('datagrid.columns.partners.background'),
      start_date:                               t('datagrid.columns.partners.start_date'),
      manage:                                   t('datagrid.columns.clients.manage'),
      changelog:                                t('datagrid.columns.clients.changelogs')
    }
    label_tag "#{column}_", label_column[column.to_sym]
  end

  def default_columns_partners_visibility(column)
    label_column = {
      address_:                      t('datagrid.columns.partners.address'),
      affiliation_:                  t('datagrid.columns.partners.affiliation'),
      background_:                   t('datagrid.columns.partners.background'),
      changelog_:                    t('datagrid.columns.clients.changelogs'),
      contact_person_mobile_:        t('datagrid.columns.partners.contact_mobile'),
      contact_person_name_:          t('datagrid.columns.partners.contact_name'),
      contact_person_email_:         t('datagrid.columns.partners.contact_email'),
      engagement_:                   t('datagrid.columns.partners.engagement'),
      id_:                           t('datagrid.columns.partners.id'),
      manage_:                       t('datagrid.columns.clients.manage'),
      name_:                         t('datagrid.columns.partners.name'),
      organisation_type_:            t('datagrid.columns.partners.organisation_type'),
      province_id_:                  t('datagrid.columns.partners.province'),
      start_date_:                   t('datagrid.columns.partners.start_date'),
    }
    label_tag "#{column}_", label_column[column.to_sym]
  end
end
