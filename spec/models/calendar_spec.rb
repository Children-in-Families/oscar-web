describe Calendar do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'class methods' do
    let!(:user_1){ create(:user) }
    let!(:user_2){ create(:user) }
    let!(:client_1){ create(:client, users: [user_1, user_2]) }
    let!(:task_1){ create(:task, user: user_1, client: client_1, name: 'My Task', completion_date: Date.today) }
    context 'populate_tasks' do
      before do
        task_1.reload
        Calendar.populate_tasks(task_1)
      end
      it 'should include tasks of case workers of the client' do
        expect(Calendar.pluck(:user_id)).to include(user_1.id)
        expect(Calendar.pluck(:user_id)).not_to include(user_2.id)
      end
    end

    context 'update_tasks' do
      before do
        Calendar.populate_tasks(task_1)

        title      = "#{task_1.domain.name} - #{task_1.name}"
        start_date = task_1.completion_date
        end_date   = (start_date + 1.day).to_s
        calendars   = Calendar.where(title: title, start_date: start_date, end_date: end_date)

        @task_params = { name: 'My Task Updated', completion_date: Date.tomorrow, domain_id: task_1.domain_id }

        Calendar.update_tasks(calendars, @task_params)
      end

      it 'should update_tasks regarding to new task params' do
        expect(Calendar.order(updated_at: :desc).first.title).to include('My Task Updated')
      end
    end
  end
end
