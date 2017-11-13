class AddPinCodeToUser < ActiveRecord::Migration
  def up
    add_column :users, :pin_code, :string, default: ''

    User.all.each do |user|
      next if user.pin_code.present?
      user.pin_code = user.pin_number.to_s
      user.save
    end
  end

  def down
    remove_column :users, :pin_code, :string, default: ''
  end
end
