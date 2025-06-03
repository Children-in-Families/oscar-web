class SessionsController < Devise::SessionsController
  include LocaleConcern

  before_action :set_whodunnit, :detect_browser
  after_action :increase_visit_count, only: :create
  skip_before_action :set_locale, only: :create

  def set_whodunnit
    if current_user
      PaperTrail::Version.where(item_id: current_user.id, whodunnit: nil).each do |v|
        v.update(whodunnit: current_user.id)
      end
    end
  end

  def increase_visit_count
    Visit.create(user: current_user)
  end
end
