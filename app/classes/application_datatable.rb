class ApplicationDatatable
  delegate :params, :class, :link_to, :content_tag, :fa_icon, to: :@view

  def initialize(view, ngo_custom_field)
    @view = view
    @ngo_custom_field = ngo_custom_field
  end

  def as_json(options = {})
    {
      recordsFiltered: total_entries,
      data: column_custom_fields
    }
  end

  private

  def page
    params[:start].to_i / per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
end
