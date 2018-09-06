class BaseGrid
  include ActionView::Helpers
  include Datagrid
  attr_accessor :current_user

  self.default_column_options = {
    # Uncomment to disable the default order
    # order: false,
    # Uncomment to make all columns HTML by default
    # html: true,
  }
  # Enable forbidden attributes protection
  # self.forbidden_attributes_protection = true

  def self.date_column(name, *args)
    column(name, *args) do |model|
      format(block_given? ? yield : model.send(name)) do |date|
        date.strftime("%d %B %Y") if date.present?
      end
    end
  end
end
