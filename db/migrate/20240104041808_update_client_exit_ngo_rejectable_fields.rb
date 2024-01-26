class UpdateClientExitNgoRejectableFields < ActiveRecord::Migration
  def up
    values = ExitNgo.with_deleted.map do |exit_ngo|
      next unless exit_ngo.client_id

      "(#{exit_ngo.client_id})"
    end.compact.join(', ')

    execute("UPDATE exit_ngos SET rejectable_id = mapping_values.client_id, rejectable_type = 'Client' FROM (VALUES #{values}) AS mapping_values (client_id) WHERE exit_ngos.client_id = mapping_values.client_id;") if values.present?
  end
end
