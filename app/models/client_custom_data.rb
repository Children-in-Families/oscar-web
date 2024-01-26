class ClientCustomData < ActiveRecord::Base
  include NestedAttributesConcern

  belongs_to :client
  belongs_to :custom_data, class_name: 'CustomData'
end
