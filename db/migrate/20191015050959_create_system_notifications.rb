class CreateSystemNotifications < ActiveRecord::Migration
  def up
    create_table :system_notifications do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.boolean :before_seven_day, default: false
      t.boolean :due_today, default: true
      t.boolean :overdue, default: true
      t.boolean :after_overdue_seven_day, default: true
      t.boolean :all_notification, default: false
      t.boolean :across_referral, default: false
      t.string :notification_type, limit: 25, default: ''

      t.timestamps null: false
    end

    SystemNotification.reset_column_information
    User.all.each do |user|
      SystemNotification::TYPES.each do |type|
        if user.admin?
          user.system_notifications.find_or_create_by(
                                                all_notification: true,
                                                across_referral: true,
                                                notification_type: type
                                              )
        elsif user.manager?
          user.system_notifications.find_or_create_by(across_referral: true, notification_type: type)
        else
          if type == 'assessment'
            user.system_notifications.find_or_create_by(notification_type: type, before_seven_day: true)
          else
            user.system_notifications.find_or_create_by(notification_type: type)
          end
        end
      end
    end
  end

  def down
    drop_table :system_notifications
  end
end
