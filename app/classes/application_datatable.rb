class ApplicationDatatable
  delegate :params, :class, :link_to, :content_tag, :fa_icon, to: :@view
  include Rails.application.routes.url_helpers

  def page
    params[:start].to_i / per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_direction
    params[:order]['0'][:dir] == 'desc' ? 'desc' : 'asc'
  end
end
