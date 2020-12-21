class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.string :image
      t.references :able_screening_question, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
