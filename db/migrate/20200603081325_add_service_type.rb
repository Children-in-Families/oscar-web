class AddServiceType < ActiveRecord::Migration[5.2]
  def up
    service = Service.find_by(name: 'Training and Education')
    Service.find_or_create_by(name: 'Literacy Support', parent_id: service.id) if service
  end

  def down
  end
end
