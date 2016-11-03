module FamiliesHelper
  def family_member_list(object)
    html_tags = []

    if params[:locale]=='km'
      html_tags << "#{I18n.t('datagrid.columns.families.female_children_count')} : #{object.female_children_count.to_i}"
    elsif params[:locale]=='en'
      html_tags << "#{I18n.t('datagrid.columns.families.female_children_count')} #{'child'.pluralize(object.female_children_count.to_i)} : #{object.female_children_count.to_i}"
    end

    if params[:locale]=='km'
      html_tags << "#{I18n.t('datagrid.columns.families.male_children_count')} : #{object.male_children_count.to_i}"
    elsif params[:locale]== 'en'
      html_tags << "#{I18n.t('datagrid.columns.families.male_children_count')} #{'child'.pluralize(object.male_children_count.to_i)} : #{object.male_children_count.to_i}"
    end

    if params[:locale]=='km'
      html_tags << "#{I18n.t('datagrid.columns.families.female_adult_count')} : #{object.female_adult_count.to_i}"
    elsif params[:locale]=='en'
      html_tags << "#{I18n.t('datagrid.columns.families.female_adult_count')} #{'adult'.pluralize(object.female_adult_count.to_i)} : #{object.female_adult_count.to_i}"
    end

    if params[:locale]=='km'
      html_tags << "#{I18n.t('datagrid.columns.families.male_adult_count')} : #{object.male_adult_count.to_i}"
    elsif params[:locale]=='en'
      html_tags << "#{I18n.t('datagrid.columns.families.male_adult_count')}#{'adult'.pluralize(object.male_adult_count.to_i)} : #{object.male_adult_count.to_i}"
    end

    content_tag(:ul, class: 'family-members-list') do
      html_tags.each do |html_tag|
        concat content_tag(:li, html_tag)
      end
    end
  end

  def family_clients_list(object)
    html_tags = []
    content_tag(:ul, class: 'family-clients-list') do
      object.cases.non_emergency.active.each do |object|
        if object.client
          name = object.client.name.present? ? object.client.name : 'Unknown'
          concat(content_tag(:li, link_to(name, client_path(object.client))))
        end
      end
    end
  end

  def family_workers_list(object)
    html_tags = []
    content_tag(:ul, class: 'family-clients-list') do
      object.joins(:user).group_by(&:user_id).each do |a|
        user = User.find(a.first)
        name = user.name.present? ? user.name : 'Unknown'
        concat(content_tag(:li, link_to(name, user_path(user))))
      end
    end
  end

end
