module PartnersHelper
  def columns_partners_visibility(column)
    label_column = {
      name:                                     t('datagrid.columns.partners.name'),
      id:                                       t('datagrid.columns.partners.id'),
      contact_person_name:                      t('datagrid.columns.partners.contact_name'),
      contact_person_email:                     t('datagrid.columns.partners.contact_email'),
      contact_person_mobile:                    t('datagrid.columns.partners.contact_mobile'),
      address:                                  t('datagrid.columns.partners.address'),
      organization_type:                        t('datagrid.columns.partners.organization_type'),
      affiliation:                              t('datagrid.columns.partners.affiliation'),
      engagement:                               t('datagrid.columns.partners.engagement'),
      background:                               t('datagrid.columns.partners.background'),
      start_date:                               t('datagrid.columns.partners.start_date'),
      manage:                                   t('datagrid.columns.clients.manage'),
      changelog:                                t('datagrid.columns.clients.changelogs'),
      **partner_address_translation
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
      organization_type_:            t('datagrid.columns.partners.organization_type'),
      start_date_:                   t('datagrid.columns.partners.start_date'),
      **partner_address_translation
    }
    label_tag "#{column}_", label_column[column.to_sym]
  end

  def partner_address_translation
    translations = {}
    translations['province_id'.to_sym] = FieldSetting.find_by(name: 'province_id', klass_name: 'partner').try(:label) || t('datagrid.columns.partners.province')
    translations['province_id_'.to_sym] = FieldSetting.find_by(name: 'province_id', klass_name: 'partner').try(:label) || t('datagrid.columns.partners.province')
    translations
  end
end
