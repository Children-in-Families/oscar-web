class UpdateUserData < ActiveRecord::Migration[5.2]
  def change
    User.all.each do |user|
      begin
        if user.uid.blank?
          user.uid = user.email
          user.save!
        end
      rescue Exception => e
        logger = Logger.new('log/modify_user.log')
        logger.info "can not modify user on #{user.id}"
      end
    end
  end
end
