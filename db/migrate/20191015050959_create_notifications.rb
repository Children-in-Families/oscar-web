class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.boolean :before_seven_day, default: false
      t.boolean :due_today, default: false
      t.boolean :overdue, default: false
      t.boolean :after_overdue_seven_day, default: false
      t.boolean :all_notification, default: false
      t.boolean :across_referral, default: false
      t.string :notification_type, limit: 25, default: ''

      t.timestamps null: false
    end

    Notification.reset_column_information
    User.all.each do |user|
      Notification::TYPES.each do |type|
        if user.admin?
          user.notifications.find_or_create_by(
                                                before_seven_day: true,
                                                due_today: true,
                                                overdue: true,
                                                after_overdue_seven_day: true,
                                                all_notification: true,
                                                across_referral: true,
                                                notification_type: type
                                              )
        elsif user.manager?
          user.notifications.find_or_create_by(across_referral: true, notification_type: type)
        else
          user.notifications.find_or_create_by(notification_type: type)
        end
      end
    end
  end

  def down
    drop_table :notifications
  end
end
