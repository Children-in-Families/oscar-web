module FormBuilderAttachmentsHelper
  def form_buildable_path(resource, index, label, params_program_stream)
    if controller_name == 'leave_programs' || controller_name == 'leave_enrolled_programs'
      link_to polymorphic_path([@client, resource.client_enrollment, resource], program_stream_id: @program_stream.id, file_index: index, file_name: label, program_streams: params_program_stream), method: :delete, data: { confirm: t('.are_you_sure') }, class: 'delete btn btn-outline btn-danger' do
        fa_icon('trash')
      end
    elsif controller_name == 'client_enrollment_trackings' || controller_name == 'client_enrolled_program_trackings'
      link_to polymorphic_path([@client, resource.client_enrollment, resource], program_stream_id: @program_stream.id, file_index: index, file_name: label, program_streams: params_program_stream), method: :delete, data: { confirm: t('.are_you_sure') }, class: 'delete btn btn-outline btn-danger' do
        fa_icon('trash')
      end
    else
      link_to polymorphic_path([@client, resource], program_stream_id: @program_stream.id, file_index: index, file_name: label), method: :delete, data: { confirm: t('.are_you_sure') }, class: 'delete btn btn-outline btn-danger' do
        fa_icon('trash')
      end
    end
  end
end
