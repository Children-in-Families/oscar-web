class AddedFieldsToEnterNgos < ActiveRecord::Migration
  def change
    add_column :enter_ngos, :follow_up_date, :datetime
    add_column :enter_ngos, :initial_referral_date, :datetime
    add_column :enter_ngos, :received_by_id, :integer
    add_column :enter_ngos, :followed_up_by_id, :integer

    add_index :enter_ngos, :follow_up_date
    add_index :enter_ngos, :initial_referral_date
    add_index :enter_ngos, :received_by_id
    add_index :enter_ngos, :followed_up_by_id

    reversible do |dir|
      dir.up do
        values = Client.joins(:enter_ngos).map do |client|
          attr = client.attributes.select(:follow_up_date, :initial_referral_date, :received_by_id, :followed_up_by_id)
          "(#{client.follow_up_date || 'NULL'}, #{client.initial_referral_date || 'NULL'}, #{client.received_by_id || 'NULL'}, #{client.followed_up_by_id || 'NULL'}, #{client.id})"
        end

        execute("UPDATE enter_ngos SET follow_up_date = mapping_values.follow_up_date, initial_referral_date = mapping_values.initial_referral_date, received_by_id = mapping_values.received_by_id, followed_up_by_id = mapping_values.followed_up_by_id FROM (VALUES #{values}) AS mapping_values (follow_up_date, initial_referral_date, received_by_id, followed_up_by_id, client_id) WHERE enter_ngos.client_id = mapping_values.client_id;") if values.present?
      end
    end
  end
end
