include CsiConcern
namespace :notifications do
  desc 'Cache all notifications'
  task :cache, [:short_name] => :environment do |task, args|
    if org.short_name
    else
      Organization.all.each do |org|
        Organization.switch_to org.short_name
        User.all.each do |user|
          setting = Setting.cache_first
          user_ability = Ability.new(@user)
          accepted_clients = Client.accessible_by(user_ability).active_accepted_status.distinct
          eligible_clients = active_young_clients(accepted_clients, setting)

          csi_assessments = user.assessment_due_today(eligible_clients, setting)
          custom_assessments = user.custom_assessment_due(eligible_clients)
          custom_forms = hser.overdue_and_due_today_forms(user, eligible_clients)

          user_custom_field = user.user_custom_field_frequency_overdue_or_due_today if user.admin? || user.manager? || user.hotline_officer?
          partner_custom_field = user.partner_custom_field_frequency_overdue_or_due_today
          family_custom_field = user.family_custom_field_frequency_overdue_or_due_today

          client_forms_overdue_or_due_today = user.client_forms_overdue_or_due_today(accepted_clients)
          case_notes_overdue_and_due_today = user.case_notes_due_today_and_overdue(accepted_clients)
        end
      end
    end
  end
end
