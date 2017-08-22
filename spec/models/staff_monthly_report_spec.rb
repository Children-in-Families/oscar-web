describe 'Staff Monthly Report' do
  let!(:user_1) { create(:user) }
  let!(:user_2) { create(:user) }
  let!(:user_3) { create(:user) }

  let!(:visit_1){ FactoryGirl.create(:visit, user: user_1, created_at: Date.today.last_month) }
  let!(:visit_2){ FactoryGirl.create(:visit, user: user_1, created_at: Date.today.last_month) }
  let!(:visits){ FactoryGirl.create_list(:visit, 32, user: user_1, created_at: Date.today.last_month) }
  let!(:user_2_visits){ FactoryGirl.create_list(:visit, 10, user: user_2, created_at: Date.today.last_month) }

  let!(:client_1) { create(:client, :accepted, users: [user_1]) }
  let!(:client_3) { create(:client, :accepted, users: [user_1, user_2]) }
  let!(:client_2) { create(:client, :accepted, users: [user_3]) }

  let!(:domain_group_1) { FactoryGirl.create(:domain_group) }
  let!(:domain_group_2) { FactoryGirl.create(:domain_group) }
  let!(:domain_group_3) { FactoryGirl.create(:domain_group) }
  let!(:domain_group_4) { FactoryGirl.create(:domain_group) }
  let!(:domain_group_5) { FactoryGirl.create(:domain_group) }
  let!(:domain_group_6) { FactoryGirl.create(:domain_group) }

  let!(:case_note) { FactoryGirl.create(:case_note, client: client_1, created_at: Date.today.last_month) }
  let!(:case_notes) { FactoryGirl.create_list(:case_note, 62, client: client_2, created_at: Date.today.last_month) }

  let!(:case_note_domain_group_1) { FactoryGirl.create(:case_note_domain_group, case_note: case_note, domain_group: domain_group_1, note: ('Test')) }
  let!(:case_note_domain_group_2) { FactoryGirl.create(:case_note_domain_group, case_note: case_note, domain_group: domain_group_2, note: ('Test')) }
  let!(:case_note_domain_group_3) { FactoryGirl.create(:case_note_domain_group, case_note: case_note, domain_group: domain_group_3, note: ('Test')) }
  let!(:case_note_domain_group_4) { FactoryGirl.create(:case_note_domain_group, case_note: case_note, domain_group: domain_group_4, note: ('Test')) }
  let!(:case_note_domain_group_5) { FactoryGirl.create(:case_note_domain_group, case_note: case_note, domain_group: domain_group_5, note: ('Test')) }
  let!(:case_note_domain_group_6) { FactoryGirl.create(:case_note_domain_group, case_note: case_note, domain_group: domain_group_6, note: ('Test')) }

  let!(:assessment_1) { FactoryGirl.create(:assessment, client: client_1, created_at: (Date.today.last_month - 8.months)) }
  let!(:assessment_2) { FactoryGirl.create(:assessment, client: client_1, created_at: Date.today.last_month) }

  let!(:assessment_3) { FactoryGirl.create(:assessment, client: client_3, created_at: (Date.today.last_month - 6.months)) }
  let!(:assessment_4) { FactoryGirl.create(:assessment, client: client_3, created_at: Date.today.last_month) }

  let!(:assessment_5) { FactoryGirl.create(:assessment, client: client_2, created_at: Date.today.last_month) }

  feature 'report' do
    scenario 'average number of daily logins' do
      expect(StaffMonthlyReport.average_number_of_daily_login(user_1)).to eq(2)
      expect(StaffMonthlyReport.average_number_of_daily_login(user_2)).to eq(1)
    end

    scenario 'average characters count of casenote' do
      expect(StaffMonthlyReport.average_casenote_characters(user_1)).to eq(24)
      expect(StaffMonthlyReport.average_casenote_characters(user_2)).to eq(0)
    end

    scenario 'average number of casenotes completed per client' do
      expect(StaffMonthlyReport.average_number_of_casenotes_completed_per_client(user_1)).to eq(1)
      expect(StaffMonthlyReport.average_number_of_casenotes_completed_per_client(user_2)).to eq(0)
    end

    scenario 'average length of time, as month, between completing CSI for each client' do
      expect(StaffMonthlyReport.average_length_of_time_completing_csi_for_each_client(user_1)).to eq(7)
      expect(StaffMonthlyReport.average_length_of_time_completing_csi_for_each_client(user_2)).to eq(6)
      expect(StaffMonthlyReport.average_length_of_time_completing_csi_for_each_client(user_3)).to eq(0)
    end
  end
end

# Done with above spec and implementation
# Remaining, time machine, task overdue and due today.
