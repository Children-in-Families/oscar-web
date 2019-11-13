module SavedSearchHelper
  def prevent_load_saved_searches(advanced_search)
    if advanced_search.program_streams.present?
      if !(@program_streams.ids & class_eval(advanced_search.program_streams)).empty?
        link_to clients_path(save_search_params(advanced_search.search_params).merge(advanced_search_id: advanced_search.id)), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
          fa_icon 'clipboard'
        end
      else
        link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-target" => "#modal-prevent_load_saved_searches", "data-toggle" => "modal", :type => "button"} do
          fa_icon 'clipboard'
        end
      end
    elsif advanced_search.custom_forms.present?
      if !(@custom_fields.ids & class_eval(advanced_search.custom_forms)).empty?
        link_to clients_path(save_search_params(advanced_search.search_params).merge(advanced_search_id: advanced_search.id)), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
          fa_icon 'clipboard'
        end
      else
        link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-target" => "#modal-prevent_load_saved_searches", "data-toggle" => "modal", :type => "button"} do
          fa_icon 'clipboard'
        end
      end
    else
      AdvancedSearch::BROKEN_SAVE_SEARCH.each do |broken_save_search|
        if broken_save_search.first == Organization.current.short_name && broken_save_search.last == advanced_search.id
          link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-target" => "#modal-prevent_load_saved_searches", "data-toggle" => "modal", :type => "button"} do
            fa_icon 'clipboard'
          end
        else
          link_to clients_path(save_search_params(advanced_search.search_params).merge(advanced_search_id: advanced_search.id)), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
            fa_icon 'clipboard'
          end
        end
      end
    end
  end

  def prevent_edit_load_saved_searches(advanced_search)
    if advanced_search.program_streams.present?
      if !(@program_streams.ids & class_eval(advanced_search.program_streams)).empty?
        link_to edit_advanced_search_save_query_path(advanced_search), class: 'btn btn-outline btn-success btn-xs' do
          fa_icon 'pencil'
        end
      else
        link_to '#', {class: 'btn btn-outline btn-success btn-xs', "data-target" => "#modal-prevent_load_saved_searches", "data-toggle" => "modal", :type => "button"} do
          fa_icon 'pencil'
        end
      end
    elsif advanced_search.custom_forms.present?
      if !(@custom_fields.ids & class_eval(advanced_search.custom_forms)).empty?
        link_to clients_path(save_search_params(advanced_search.search_params).merge(advanced_search_id: advanced_search.id)), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
          fa_icon 'clipboard'
        end
      else
        link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-target" => "#modal-prevent_load_saved_searches", "data-toggle" => "modal", :type => "button"} do
          fa_icon 'clipboard'
        end
      end
    else
      link_to edit_advanced_search_save_query_path(advanced_search), class: 'btn btn-outline btn-success btn-xs' do
        fa_icon 'pencil'
      end
    end
  end
end
