module Api
  module V1
    class NotificationsController < Api::V1::BaseApiController
      def index
        clients = Client.accessible_by(current_ability).non_exited_ngo
        @notifications = UserNotification.new(current_user, clients)
        notifications = JSON.parse(@notifications.to_json)
        notifications = {
          all_count: notifications['all_count'],
          assessment: {
            overdue_count: notifications['assessments']['overdue_count'],
            due_today_count: notifications['assessments']['due_today'].size,
            upcoming_csi_count: notifications['upcoming_csi_assessments_count'],
            path: ''
          },
          custom_assessment: {
            overdue_count: notifications['assessments']['custom_overdue_count'],
            due_today_count: notifications['assessments']['custom_due_today'].size,
            upcoming_count: notifications['upcoming_custom_csi_assessments_count'],
            path: ''
          },
          user_custom_forms: {
            overdue_count: notifications['user_custom_field']['entity_overdue'].size,
            due_today_count: notifications['user_custom_field']['entity_due_today'].size,
            path: ''
          },
          client_custom_forms: {
            overdue_count: notifications['client_forms_overdue_or_due_today']['overdue_forms'].size,
            due_today_count: notifications['client_forms_overdue_or_due_today']['today_forms'].size,
            upcomming_count: notifications['client_forms_overdue_or_due_today']['upcoming_forms'].size,
            path: ''
          },
          family_custom_forms: {
            overdue_count: notifications['family_custom_field']['entity_overdue'].size,
            due_today_count: notifications['family_custom_field']['entity_due_today'].size,
            path: ''
          },
          partner_custom_forms: {
            overdue_count: notifications['partner_custom_field']['entity_overdue'].size,
            due_today_count: notifications['partner_custom_field']['entity_due_today'].size,
            path: ''
          },
          case_notes: {
            overdue_count: notifications['case_notes_overdue_and_due_today']['client_overdue'].size,
            due_today_count: notifications['case_notes_overdue_and_due_today']['client_due_today'].size,
            path: ''
          },
          get_referrals: {
            count: notifications['get_referrals'].size,
            path: ''
          },
          repeat_family_referrals: {
            count: notifications['repeat_family_referrals'].size,
            path: ''
          },
          tasks: {
            overdue_count: 0,
            due_today_count: 0,
            upcoming_csi_count: 0,
            path: ''
          },
          unsaved_family_referrals: {
            count: notifications['unsaved_family_referrals'].size,
            path: ''
          }
        }
        render json: notifications
      end
    end
  end
end
