class CreateReferralHistories < ActiveRecord::Migration
  def change
    create_table :referral_histories do |t|
      t.integer :client_id
      t.integer :followed_up_by_id
      t.integer :received_by_id
      t.integer :enter_ngo_id
      t.datetime :referral_date
      t.datetime :follow_up_date
      t.integer :user_ids, default: [], array: true
      t.index [:client_id], name: :index_client_id_on_referral_histories
      t.index [:enter_ngo_id], name: :index_enter_ngo_id_on_referral_histories

      t.timestamps null: false
    end

    ReferralHistory.reset_column_information

    reversible do |dir|
      dir.up do
        values = Client.all.map do |client|
          "(#{client.follow_up_date && "'#{client.follow_up_date.to_s}'" || 'NULL'}, '#{(client.initial_referral_date || client.created_at).to_s}', #{client.received_by_id || 'NULL'}, #{client.followed_up_by_id || 'NULL'}, #{client.id})"
        end.join(', ')

        if values.present?
          # Update code below to CREATE referral_histories instead of UPDATE enter_ngos
          execute <<-SQL.squish
              INSERT INTO referral_histories (follow_up_date, referral_date, received_by_id, followed_up_by_id, client_id, created_at, updated_at)
              SELECT
                mapping_values.follow_up_date::timestamp,
                mapping_values.initial_referral_date::timestamp,
                NULLIF(mapping_values.received_by_id, NULL)::integer,
                NULLIF(mapping_values.followed_up_by_id, NULL)::integer,
                mapping_values.client_id::integer,
                NOW(),
                NOW()
              FROM (VALUES #{values}) AS mapping_values (follow_up_date, initial_referral_date, received_by_id, followed_up_by_id, client_id)
            SQL
        end
      end
    end
  end
end
