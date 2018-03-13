describe 'Staff Monthly Report' do
  before do
    TaskHistory.destroy_all
  end
  let!(:user_1) { create(:user) }
  let!(:user_2) { create(:user) }
  let!(:user_3) { create(:user) }
  let!(:user_4) { create(:user) }
  let!(:user_5) { create(:user) }

  let!(:user_1_tasks) { create_list(:task, 2, :incomplete, completion_date: Date.today.last_month.beginning_of_month, user: user_1) }
  let!(:user_2_tasks) { create_list(:task, 16, :incomplete, completion_date: Date.today.last_month.beginning_of_month, user: user_2) }
  let!(:user_3_tasks) { create(:task, :incomplete, completion_date: Date.today.last_month.end_of_month, user: user_3) }

  let!(:client_1) { create(:client, :accepted, users: [user_1]) }
  let!(:client_3) { create(:client, :accepted, users: [user_1, user_2]) }
  let!(:client_2) { create(:client, :accepted, users: [user_3]) }
  let!(:client_4) { create(:client, :accepted, users: [user_3]) }
  let!(:client_5) { create(:client, :accepted, users: [user_5]) }
  let!(:three_clients) { create_list(:client, 3, :accepted, users: [user_4]) }

  let!(:domain_group_1) { create(:domain_group) }
  let!(:domain_group_2) { create(:domain_group) }

  let!(:case_note) { create(:case_note, client: client_1, created_at: Date.today.last_month) }
  let!(:case_note_1) { create(:case_note, client: client_1, created_at: Date.today.last_month) }
  let!(:case_notes) { create_list(:case_note, 5, client: client_2, created_at: Date.today.last_month) }
  let!(:case_note_2) { create(:case_note, client: user_4.clients.last, created_at: Date.today.last_month) }

  let!(:case_note_domain_group_1) { create_list(:case_note_domain_group, 6, case_note: case_note, domain_group: domain_group_1, note: ('Test')) }
  let!(:case_note_domain_group_2) { create_list(:case_note_domain_group, 6, case_note: case_note_1, domain_group: domain_group_2, note: ('Yeh')) }

  let!(:assessment_1) { create(:assessment, client: client_1, created_at: (Date.today.last_month - 6.months)) }
  let!(:assessment_2) { create(:assessment, client: client_1, created_at: Date.today.last_month) }
  let!(:assessment_3) { create(:assessment, client: client_3, created_at: (2.days.ago.last_month - 6.months)) }
  let!(:assessment_4) { create(:assessment, client: client_3, created_at: Date.today.last_month) }

  let!(:assessment_5) { create(:assessment, client: client_5, created_at: Date.today.last_month - 6.months) }
  let!(:assessment_6) { create(:assessment, client: client_5, created_at: Date.today.last_month) }

  let!(:user_1_visit_clients) { create_list(:visit_client, 3, user: user_1, created_at: Date.today.last_month) }
  let!(:user_4_visit_clients) { create_list(:visit_client, 2, user: user_4, created_at: Date.today.last_month) }

  xfeature 'report' do
    scenario 'number of times visiting clients' do
      expect(StaffMonthlyReport.times_visiting_clients_profile(user_1)).to eq(3)
      expect(StaffMonthlyReport.times_visiting_clients_profile(user_4)).to eq(2)
      expect(StaffMonthlyReport.times_visiting_clients_profile(user_2)).to eq(0)
      expect(StaffMonthlyReport.times_visiting_clients_profile(user_3)).to eq(0)
      expect(StaffMonthlyReport.times_visiting_clients_profile(user_5)).to eq(0)
    end

    scenario 'average characters count of casenote' do
      expect(StaffMonthlyReport.average_casenote_characters(user_1)).to eq(21.0)
      expect(StaffMonthlyReport.average_casenote_characters(user_2)).to eq(0)
    end

    scenario 'average number of casenotes completed per client' do
      expect(StaffMonthlyReport.average_number_of_casenotes_completed_per_client(user_1)).to eq(1.0)
      expect(StaffMonthlyReport.average_number_of_casenotes_completed_per_client(user_2)).to eq(0.0)
      expect(StaffMonthlyReport.average_number_of_casenotes_completed_per_client(user_3)).to eq(2.5)
      expect(StaffMonthlyReport.average_number_of_casenotes_completed_per_client(user_4)).to eq(0.33)
    end

    feature 'average length of time, as days, between completing CSI for each client' do
      scenario 'user_1' do
        client_1_second_most_recent_assessment = client_1.assessments.order(:created_at).first.created_at.to_date
        client_1_most_recent_assessment = client_1.assessments.order(:created_at).second.created_at.to_date
        client_1_duration = (client_1_most_recent_assessment - client_1_second_most_recent_assessment).to_i

        client_3_second_most_recent_assessment = client_3.assessments.order(:created_at).first.created_at.to_date
        client_3_most_recent_assessment = client_3.assessments.order(:created_at).second.created_at.to_date
        client_3_duration = (client_3_most_recent_assessment - client_3_second_most_recent_assessment).to_i

        total_duration = client_1_duration + client_3_duration
        client_count = user_1.clients.count
        expect(StaffMonthlyReport.average_length_of_time_completing_csi_for_each_client(user_1)).to eq((total_duration / client_count).round(2))
      end
      scenario 'user_5' do
        client_5_second_most_recent_assessment = client_5.assessments.order(:created_at).first.created_at.to_date
        client_5_most_recent_assessment = client_5.assessments.order(:created_at).second.created_at.to_date
        client_5_duration = (client_5_most_recent_assessment - client_5_second_most_recent_assessment).to_i
        total_duration = client_5_duration
        client_count = user_5.clients.count
        expect(StaffMonthlyReport.average_length_of_time_completing_csi_for_each_client(user_5)).to eq((total_duration / client_count).round(2))
      end
    end

    scenario 'average number of due today tasks each day' do
      TaskHistory.update_all(created_at: Date.today.last_month, updated_at: Date.today.last_month)
      expect(StaffMonthlyReport.average_number_of_duetoday_tasks_each_day(user_1)).to be_between(0.06, 0.07).inclusive
      expect(StaffMonthlyReport.average_number_of_duetoday_tasks_each_day(user_2)).to be_between(0.52, 0.53).inclusive
      expect(StaffMonthlyReport.average_number_of_duetoday_tasks_each_day(user_3)).to be_between(0.02, 0.03).inclusive
    end

    scenario 'average number of overdue tasks each day' do
      TaskHistory.update_all(created_at: Date.today.last_month, updated_at: Date.today.last_month)
      expect(StaffMonthlyReport.average_number_of_overdue_tasks_each_day(user_1)).to be_between(0.06, 0.07).inclusive
      expect(StaffMonthlyReport.average_number_of_overdue_tasks_each_day(user_2)).to be_between(0.52, 0.53).inclusive
      expect(StaffMonthlyReport.average_number_of_overdue_tasks_each_day(user_3)).to be_between(0.02, 0.03).inclusive
    end
  end
end
