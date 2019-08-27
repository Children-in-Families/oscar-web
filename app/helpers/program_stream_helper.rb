module ProgramStreamHelper

  def format_rule(rules)
    if rules['rules'].present? && rules['rules'].any?
      forms_prefixed = ['domainscore', 'formbuilder', 'tracking', 'enrollment', 'enrollmentdate', 'programexitdate', 'exitprogram', 'quantitative']
      rules['rules'].each do |rule|
        if rule['rules'].present?
          format_rule(rule)
        elsif forms_prefixed.any?{ |form| rule['id'].include?(form) }
          rule['id']    = rule['id'].gsub(/_/, '__') if rule['id'].exclude?('__')
          rule['field'] = rule['field'].gsub(/_/, '__') if rule['field'].exclude?('__')
        end
      end
    end
    rules
  end

  def html_column(full_width)
    full_width ? '' : 'col-md-6'
  end

  def delete_button(program)
    if program.client_enrollments.empty?
      link_to program_stream_path(program), method: 'delete',  data: { confirm: t('.are_you_sure') }, class: 'btn btn-outline btn-danger btn-xs' do
        fa_icon('trash')
      end
    elsif program.client_enrollments.active.empty?
      link_to program_stream_path(program), method: 'delete',  data: { confirm: t('.warning_message') }, class: 'btn btn-outline btn-danger btn-xs' do
        fa_icon('trash')
      end
    else
      content_tag(:div, '', class: 'btn btn-outline btn-danger btn-xs disabled') do
        fa_icon('trash')
      end
    end
  end

  def program_stream_redirect_path
    params[:client] == 'true' ? request.referer : program_streams_path
  end

  def format_placeholder(value)
    value.gsub('-', ' ').gsub('&amp;qoute;', '&quot;').html_safe if value.present?
  end

  def services(parent_include = true)
    service_parents = Service.only_parents
    parents = service_parents.map do |service|
      [service.name, service.id]
    end

    service_children = Service.only_children
    children = []

    ids = service_children.ids
    children = find_children(service_parents, ids, children)

    results = parent_include ?  parents + children : children
  end

  def find_children(service_parents, ids, children)
    the_ids = ids
    return children if ids.blank?
    service_parents.ids.map do |parent_id|
      child = Service.where(id: the_ids).find_by(parent_id: parent_id)
      if child
        children << [child.name, child.id]
        the_ids.delete(child.id)
      else
        children << ['', '']
      end
    end
    find_children(service_parents, the_ids, children)
  end

  private 
    #store option of each form builder for enrollment tab 
    def custom_option_form_builder_enrollment(program_stream)
      all_option_form_choosen_by_client_enrollment(program_stream)
      @select_option_enrollment   = all_option_form_choosen_by_client_enrollment(program_stream)["select"]&.reject(&:blank?)
      @checkbox_option_enrollment = all_option_form_choosen_by_client_enrollment(program_stream)["checkbox-group"]&.reject(&:blank?)
      @radio_option_enrollment    = all_option_form_choosen_by_client_enrollment(program_stream)["radio-group"]&.reject(&:blank?)
    end
    def all_option_form_choosen_by_client_enrollment(program_stream)
      all_option_form_by_type_and_label_enrollment(program_stream)
      all_option_form_program_stream_enrollment(program_stream)
      @all_choosen_enrollment_form_value_by_type = Hash.new{|h,k| h[k] = []} 
      @all_choosen_option_form.each do |choosen_option|
        @option_form.each do |key,values|
          next unless values.present? 
          values.each do |v|
            @all_choosen_enrollment_form_value_by_type[key] << choosen_option[v] if choosen_option[v]
          end
        end
      end
      @all_choosen_enrollment_form_value_by_type =  @all_choosen_enrollment_form_value_by_type.transform_values(&:flatten)
      @all_choosen_enrollment_form_value_by_type =  @all_choosen_enrollment_form_value_by_type.transform_values(&:uniq)
    end

    def all_option_form_by_type_and_label_enrollment(program_stream)
      @all_choosen_option_form = []
      program_stream.client_enrollments.each do |ps_client_enrollment|
        choosen_option_form = ps_client_enrollment.properties if ps_client_enrollment.properties.present? 
        @all_choosen_option_form << choosen_option_form
      end
    end

    def all_option_form_program_stream_enrollment(program_stream)
      @option_form = Hash.new{|h,k| h[k] = []} 
      option_form_enrollment(program_stream)
      @custom_option_form["type"].each_with_index do |type_option_enrollment,i|
        @option_form[type_option_enrollment] << @custom_option_form["label"][i]
      end
    end

    def option_form_enrollment(program_stream)
      @custom_option_form = Hash.new{|h,k| h[k] = []} 
      program_stream.enrollment.each do |enrollment|
        enrollment.each do |k,v|
          next unless k[/^(type|label)$/i]
          @custom_option_form[k] << v 
        end
      end
    end

    #store option of each form builder for tracking tab 
    def custom_option_form_builder_tracking(program_stream)
      all_option_form_choosen_by_tracking(program_stream)
      @select_option_tracking     = all_option_form_choosen_by_tracking(program_stream)["select"]&.reject(&:blank?)
      @checkbox_option_tracking   = all_option_form_choosen_by_tracking(program_stream)["checkbox-group"]&.reject(&:blank?)
      @radio_option_tracking      = all_option_form_choosen_by_tracking(program_stream)["radio-group"]&.reject(&:blank?)
    end
    def all_option_form_choosen_by_tracking(program_stream)
      all_option_form_by_type_and_label_tracking(program_stream)
      all_option_form_program_stream_tracking(program_stream)
      @all_choosen_tracking_form_value_by_type = Hash.new{|h,k| h[k] = []} 
      @all_choosen_option_form_tracking.each do |choosen_option|
        @option_form_tracking.each do |key,values|
          next unless values.present?
          values.each do |v|
            @all_choosen_tracking_form_value_by_type[key] << choosen_option[v] if choosen_option[v]
          
          end
        end
      end
      @all_choosen_tracking_form_value_by_type =  @all_choosen_tracking_form_value_by_type.transform_values(&:flatten)
      @all_choosen_tracking_form_value_by_type =  @all_choosen_tracking_form_value_by_type.transform_values(&:uniq)
    end

    def all_option_form_by_type_and_label_tracking(program_stream)
      @all_choosen_option_form_tracking = []
      program_stream.client_enrollments.each do |ps_client_enrollment|
        ps_client_enrollment.client_enrollment_trackings.each do |ps_client_enrollment_tracking|
          choosen_option_form_tracking = ps_client_enrollment_tracking.properties if ps_client_enrollment_tracking.properties.present?
          @all_choosen_option_form_tracking <<  choosen_option_form_tracking 
        end
      end
    end

    def all_option_form_program_stream_tracking(program_stream)
      @option_form_tracking = Hash.new{|h,k| h[k] = []} 
      option_form_tracking(program_stream)
      @custom_option_form_tracking["type"].each_with_index do |type_option_tracking,i|
        @option_form_tracking[type_option_tracking] << @custom_option_form_tracking["label"][i]
      end
    end

    def option_form_tracking(program_stream)
      @custom_option_form_tracking = Hash.new{|h,k| h[k] = []} 
      program_stream.trackings.each do |tracking|
        tracking.fields.each do |tracking_field|
          tracking_field.each do |k,v|
            next unless k[/^(type|label)$/i]
            @custom_option_form_tracking[k] << v 
          end
        end
      end
    end

    #store option of each form builder for exit program tab 
    def custom_option_form_builder_exit_program(program_stream)
      all_option_form_choosen_by_exit_program(program_stream)
      @select_option_exiting      = all_option_form_choosen_by_exit_program(program_stream)["select"]&.reject(&:blank?)
      @checkbox_option_exiting    = all_option_form_choosen_by_exit_program(program_stream)["checkbox-group"]&.reject(&:blank?)
      @radio_option_exiting       = all_option_form_choosen_by_exit_program(program_stream)["radio-group"]&.reject(&:blank?)
    end
    def all_option_form_choosen_by_exit_program(program_stream)
      all_option_form_by_type_and_label_exit_program(program_stream)
      all_option_form_program_stream_exit_program(program_stream)
      @all_choosen_exit_program_form_value_by_type = Hash.new{|h,k| h[k] = []} 
      @all_choosen_option_form_exit_program.compact.each do |choosen_option|
        @option_form_exit_program.each do |key,values|
          next unless values.present?
          values.each do |v|
            @all_choosen_exit_program_form_value_by_type[key] << choosen_option[v] if choosen_option[v].present?
          end
        end
      end
      @all_choosen_exit_program_form_value_by_type =  @all_choosen_exit_program_form_value_by_type.transform_values(&:flatten)
      @all_choosen_exit_program_form_value_by_type =  @all_choosen_exit_program_form_value_by_type.transform_values(&:uniq)
    end

    def all_option_form_by_type_and_label_exit_program(program_stream)
      @all_choosen_option_form_exit_program = []
      program_stream.client_enrollments.each do |ps_client_enrollment|
        choosen_option_form_exit_program = ps_client_enrollment.leave_program.properties if ps_client_enrollment.leave_program&.properties.present?
        @all_choosen_option_form_exit_program << choosen_option_form_exit_program
      end
    end

    def all_option_form_program_stream_exit_program(program_stream)
      @option_form_exit_program = Hash.new{|h,k| h[k] = []} 
      option_form_exit_program(program_stream)
      @custom_option_form_exit_program["type"].each_with_index do |type_option_exit,i|
        @option_form_exit_program[type_option_exit] <<  @custom_option_form_exit_program["label"][i]
      end
    end

    def option_form_exit_program(program_stream)
      @custom_option_form_exit_program = Hash.new{|h,k| h[k] = []} 
      program_stream.exit_program.each do |exit_program|
        exit_program.each do |k,v|
          next unless k[/^(type|label)$/i]
          @custom_option_form_exit_program[k] << v
        end
      end
    end
end
