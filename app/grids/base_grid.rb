class BaseGrid
  include ActionView::Helpers
  include Datagrid

  attr_accessor :current_user

  self.default_column_options = {
  }

  def self.date_column(name, *args)
    column(name, *args) do |model|
      if block_given?
        format(block_given? ? yield : model.send(name)) do |date|
          date.strftime("%d %B %Y") if date.present?
        end
      else
        model.send(name).present? ? model.send(name).strftime("%d %B %Y") : ''
      end
    end
  end

  private

  def current_setting
    @current_setting ||= Setting.first
  end
end
