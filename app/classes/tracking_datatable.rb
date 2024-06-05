class TrackingDatatable < ApplicationDatatable
  def initialize(view)
    @view = view
    @fetch_trackings = fetch_trackings
  end

  def as_json(options = {})
    {
      recordsFiltered: total_entries,
      data: column_program_streams
    }
  end

  private

  def sort_column
    column = columns[params[:order]['0'][:column].to_i]
    if column == 'program_stream_name'
      'program_streams.name'
    else
      'trackings.name'
    end
  end

  def fetch_trackings
    program_stream_ids = ClientEnrollment.active.pluck(:program_stream_id).uniq
    Tracking.unscoped.visible.includes(:client_enrollments, :program_stream).where(program_streams: { id: program_stream_ids }).order("lower(#{sort_column}), trackings.id  #{sort_direction}").page(page).per(per_page)
  end

  def columns
    %w(program_stream_name name copy)
  end

  def column_program_streams
    @fetch_trackings.map { |t| [t.program_stream.name, t.name, link_program_stream(t)] }
  end

  def link_program_stream(tracking)
    link_to new_multiple_form_tracking_client_tracking_path(tracking), class: 'btn btn-primary btn-sm' do
      I18n.t('dashboards.program_streams_tab.open_form')
    end
  end

  def total_entries
    @fetch_trackings.total_count
  end
end
