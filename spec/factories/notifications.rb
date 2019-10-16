FactoryGirl.define do
  factory :notification do
    user nil
    before_seven_day false
    due_today false
    overdue false
    after_overdue_seven_day false
    all_notification false
    notification_type "MyString"
  end
end
