class CreateInternalReferralProgramStreams < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_referral_program_streams do |t|
      t.references :internal_referral, index: true, foreign_key: true
      t.references :program_stream, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
