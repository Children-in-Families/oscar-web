module SavedSearchHelper
  def check_saved_searches(advanced_search)
    if advanced_search.program_streams.present?
      if !(@program_streams.ids & class_eval(advanced_search.program_streams)).empty?
        link_to clients_path(save_search_params(advanced_search.search_params).merge(advanced_search_id: advanced_search.id)), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
          fa_icon 'clipboard'
        end
      else
        link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-target" => "#modal-prevent-show-my-save-search", "data-toggle" => "modal", :type => "button"} do
          fa_icon 'clipboard'
        end
      end
    else
      link_to clients_path(save_search_params(advanced_search.search_params).merge(advanced_search_id: advanced_search.id)), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
        fa_icon 'clipboard'
      end
    end
  end
end
