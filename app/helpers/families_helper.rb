module FamiliesHelper
  def family_member_list(object)
    html_tags = []

    if params[:locale] == 'km'
      html_tags << "#{I18n.t('datagrid.columns.families.female_children_count')} : #{object.female_children_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.male_children_count')} : #{object.male_children_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.female_adult_count')} : #{object.female_adult_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.male_adult_count')} : #{object.male_adult_count.to_i}"
    elsif params[:locale] == 'en'
      html_tags << "#{I18n.t('datagrid.columns.families.female')} #{'child'.pluralize(object.female_children_count.to_i)} : #{object.female_children_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.male')} #{'child'.pluralize(object.male_children_count.to_i)} : #{object.male_children_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.female')} #{'adult'.pluralize(object.female_adult_count.to_i)}  : #{object.female_adult_count.to_i}"
      html_tags << "#{I18n.t('datagrid.columns.families.male')} #{'adult'.pluralize(object.male_adult_count.to_i)} : #{object.male_adult_count.to_i}"
    end

    content_tag(:ul, class: 'family-members-list') do
      html_tags.each do |html_tag|
        concat content_tag(:li, html_tag)
      end
    end
  end

  def family_clients_list(object)
    content_tag(:ul, class: 'family-clients-list') do
      object.children.each do |child_id|
        client = Client.find_by(id: child_id)
        concat(content_tag(:li, link_to(entity_name(client), client_path(client)))) if client.present?
      end
    end
  end

  def family_workers_list(object)
    content_tag(:ul, class: 'family-clients-list') do
      user_ids = Client.joins(:cases).where(cases: { id: object.ids }).joins(:case_worker_clients).map(&:user_ids).flatten.uniq
      User.where(id: user_ids).each do |user|
        concat(content_tag(:li, link_to(entity_name(user), user_path(user))))
      end
    end
  end

  def family_workers_count(object)
    Client.joins(:cases).where(cases: { id: object.ids }).joins(:case_worker_clients).map(&:user_ids).flatten.uniq.size
  end

  def family_case_history(object)
    if object.case_history =~ /\A#{URI::regexp(['http', 'https'])}\z/
      link_to object.case_history, object.case_history, class: 'case-history', target: :_blank
    else
      object.case_history
    end
  end
end
