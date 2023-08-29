class CreateAhoyMessages < ActiveRecord::Migration
  def change
    create_table :ahoy_messages do |t|
      t.references :user, polymorphic: true
      t.text :to
      t.string :mailer
      t.text :subject
      t.timestamp :sent_at
    end
  end
end
