module SavedSearchHelper
  private
    def prevent_load_saved_searches(advanced_search)
      if (current_organization.short_name == "mtp" && AdvancedSearch::BROKEN_RULE_MTP.include?(advanced_search.id)) || (current_organization.short_name == "demo" && AdvancedSearch::BROKEN_RULE_DEMO.include?(advanced_search.id))
        link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-toggle" => "popover","data-content" => "Program stream, rule or custom form has been deleted.", "data-placement" => "top","data-trigger" => "hover", :type => "button"} do
          fa_icon 'clipboard'
        end
      elsif advanced_search.program_streams.present?
        if !(@program_streams.map(&:id) & class_eval(advanced_search.program_streams)).empty?
          link_to url_for(["#{advanced_search.search_for.pluralize.to_sym}", polymorphic_saved_search_params(advanced_search).merge(advanced_search_id: advanced_search.id, commit: 'commit')]), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
            fa_icon 'clipboard'
          end
        else
          link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-toggle" => "popover","data-content" => "Program stream,rule or custom form has been deleted.", "data-placement" => "top","data-trigger" => "hover", :type => "button"} do
            fa_icon 'clipboard'
          end
        end
      elsif advanced_search.custom_forms.present?
        if !(@custom_fields.map(&:id) & class_eval(advanced_search.custom_forms)).empty?
          link_to url_for(["#{advanced_search.search_for.pluralize.to_sym}", polymorphic_saved_search_params(advanced_search).merge(advanced_search_id: advanced_search.id, commit: 'commit')]), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
            fa_icon 'clipboard'
          end
        else
          link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-toggle" => "popover","data-content" => "Program stream,rule or custom form has been deleted.", "data-placement" => "top","data-trigger" => "hover", :type => "button"} do
            fa_icon 'clipboard'
          end
        end
      else
        blank_save_search(advanced_search)
      end
    end

    def blank_save_search(advanced_search)
      current_org = current_organization.short_name
      advanced_search_id = advanced_search.id
      custom_advanced_search = [current_org, advanced_search_id]
      if AdvancedSearch::BROKEN_SAVE_SEARCH.include?(custom_advanced_search)
        link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-toggle" => "popover","data-content" => "Program stream,rule or custom form has been deleted.", "data-placement" => "top","data-trigger" => "hover",:type => "button"} do
          fa_icon 'clipboard'
        end
      else
        link_to url_for(["#{advanced_search.search_for.pluralize.to_sym}", polymorphic_saved_search_params(advanced_search).merge(advanced_search_id: advanced_search.id, commit: 'commit')]), class: 'btn btn-xs btn-success btn-outline dany', data: { "save-search-#{advanced_search.id}": advanced_search.queries.to_json } do
          fa_icon 'clipboard'
        end
      end
    end

    def polymorphic_saved_search_params(search)
      search_params = save_search_params(search.search_params)
      search_params[:family_advanced_search] = search_params.delete(:client_advanced_search) if search.try(:search_for_family?)
      search_params
    end

    def prevent_edit_load_saved_searches(advanced_search)
      if advanced_search.program_streams.present?
        if !(@program_streams.map(&:id) & class_eval(advanced_search.program_streams)).empty?
          link_to edit_advanced_search_save_query_path(advanced_search), remote: params[:advanced_search_id] == "#{advanced_search.id}", class: 'btn btn-outline btn-success btn-xs' do
            fa_icon 'pencil'
          end
        else
          link_to '#', {class: 'btn btn-outline btn-success btn-xs', "data-toggle" => "popover","data-content" => "Program stream,rule or custom form has been deleted.", "data-placement" => "top","data-trigger" => "hover", :type => "button"} do
            fa_icon 'pencil'
          end
        end
      elsif advanced_search.custom_forms.present?
        if !(@custom_fields.map(&:id) & class_eval(advanced_search.custom_forms)).empty?
          link_to edit_advanced_search_save_query_path(advanced_search), remote: params[:advanced_search_id] == "#{advanced_search.id}", class: 'btn btn-outline btn-success btn-xs' do
            fa_icon 'pencil'
          end
        else
          link_to '#', {class: 'btn btn-xs btn-success btn-outline', "data-toggle" => "popover","data-content" => "Program stream,rule or custom form has been deleted.", "data-placement" => "top","data-trigger" => "hover", :type => "button"} do
            fa_icon 'pencil'
          end
        end
      else
        blank_edit_save_search(advanced_search)
      end
    end

    def blank_edit_save_search(advanced_search)
      current_org = current_organization.short_name
      advanced_search_id = advanced_search.id
      custom_advanced_search = [current_org, advanced_search_id]
      if AdvancedSearch::BROKEN_SAVE_SEARCH.include?(custom_advanced_search)
        link_to '#', {class: 'btn btn-xs btn-success btn-outline',"data-toggle" => "popover","data-content" => "Program stream,rule or custom form has been deleted.", "data-placement" => "top","data-trigger" => "hover", :type => "button"} do
          fa_icon 'pencil'
        end
      else
        link_to edit_advanced_search_save_query_path(advanced_search), remote: params[:advanced_search_id] == "#{advanced_search.id}", class: 'btn btn-outline btn-success btn-xs' do
          fa_icon 'pencil'
        end
      end
    end
end
