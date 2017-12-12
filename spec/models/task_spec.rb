describe Task, 'associations' do
  it { is_expected.to belong_to(:domain)}
  it { is_expected.to belong_to(:case_note_domain_group)}
  it { is_expected.to belong_to(:client)}

  it { is_expected.to have_many(:case_worker_tasks).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:case_worker_tasks) }
end

describe Task, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:domain) }
  it { is_expected.to validate_presence_of(:completion_date) }
end

describe Task, 'scopes' do
  let!(:active_client){ create(:client) }
  let!(:exited_ngo_client){ create(:client, status: Client::EXIT_STATUSES.first) }
  let!(:domain){ create(:domain)}
  let!(:task){ create(:task, domain: domain, client: active_client)}
  let!(:task_other){ create(:task, client: exited_ngo_client)}
  let!(:completed_task){ create(:task, completed: true) }
  let!(:incomplete_task){ create(:task, completed: false) }
  let!(:overdue_task){ create(:task, completion_date: Date.today - 1.month) }
  let!(:today_task){ create(:task, completion_date: Date.today) }
  let!(:upcoming_task){ create(:task, completion_date: Date.today + 1.month) }

  context 'exclude_exited_ngo_clients' do
    subject{ Task.exclude_exited_ngo_clients }
    it 'should return records of clients who are not exited the ngo' do
      is_expected.to include(task)
    end

    it 'should not return records of clients who are exited the ngo' do
      is_expected.not_to include(task_other)
    end
  end

  context 'by_domain_id' do
    subject{ Task.by_domain_id(domain.id) }
    it 'should include by domain task' do
      is_expected.to include(task)
    end
    it 'should not include domain task' do
      is_expected.not_to include(task_other)
    end
  end

  context 'completed' do
    subject{ Task.completed }
    it 'should include completed task' do
      is_expected.to include(completed_task)
    end
    it 'should not include incomplete task' do
      is_expected.not_to include(incomplete_task)
    end
  end
  context 'incomplete' do
    subject{ Task.incomplete }
    it 'should include incomplete task' do
      is_expected.to include(incomplete_task)
    end
    it 'should not include completed task' do
      is_expected.not_to include(completed_task)
    end
  end

  context 'overdue' do
    subject{ Task.overdue }
    it 'should include overdue task' do
      is_expected.to include(overdue_task)
    end
    it 'should not include not overdue task' do
      is_expected.not_to include(today_task)
      is_expected.not_to include(upcoming_task)
    end
  end

  context 'today' do
    subject{ Task.today }
    it 'should include today task' do
      is_expected.to include(today_task)
    end
    it 'should not include not today task' do
      is_expected.not_to include(overdue_task)
      is_expected.not_to include(upcoming_task)
    end
  end

  context 'upcoming' do
    subject{ Task.upcoming }
    it 'should include upcoming task' do
      is_expected.to include(upcoming_task)
    end
    it 'should not include not today task' do
      is_expected.not_to include(overdue_task)
      is_expected.not_to include(today_task)
    end
  end
end

describe Task, 'methods' do
  let!(:user){ create(:user) }
  let!(:other_user){ create(:user) }
  let!(:client) { create(:client, user_ids: [user.id]) }
  let!(:other_client) { create(:client) }
  let!(:task){ create(:task, user_ids: client.user_ids, client: client) }
  let!(:other_task){ create(:task, user_ids: other_client.user_ids, client: other_client) }

  context 'of user' do
    subject{ Task.of_user(user) }
    it 'should include task of user' do
      is_expected.to include(task)
    end
    it 'should not include task of other user' do
      is_expected.not_to include(other_task)
    end
  end

  context 'set complete' do
    before do
      Task.set_complete
      task.reload
      other_task.reload
    end
    it 'should set all task completed' do
      expect(task.completed).to be_truthy
      expect(other_task.completed).to be_truthy
    end
  end

  context 'filter' do
    it 'should include user task' do
      params = { user_id: user.id }
      expect(Task.filter(params)).to include(task)
    end
    it 'should include all task' do
      expect(Task.filter({})).to eq(Task.all)
    end
  end

  context 'under' do
    subject{ Task.under(user, client) }
    it 'should include task of user under client' do
      is_expected.to include(task)
    end
    it 'should not include task of user under other client' do
      is_expected.not_to include(other_task)
    end
    it 'should not include task of other user under client' do
      is_expected.not_to include(other_task)
    end
  end

  context 'by_case_note_domain_group' do
    let!(:domain_group){ create(:domain_group) }
    let!(:domain){ create(:domain, domain_group: domain_group) }
    let!(:cdg){ create(:case_note_domain_group, domain_group: domain_group) }
    let!(:task){ create(:task, case_note_domain_group: cdg, completed: true) }
    let!(:incomplete_task){ create(:task, domain: domain) }
    let!(:other_task){ create(:task, completed: true) }
    subject { Task.by_case_note_domain_group(cdg) }
    it 'should include incomplete tasks and tasks of case_note_domain_group' do
      is_expected.to include(task, incomplete_task)
      is_expected.not_to include(other_task)
    end
  end
end

describe User, 'callbacks' do
  let!(:case_worker_a){ create(:user, :case_worker) }
  let!(:case_worker_b){ create(:user, :case_worker) }
  let!(:case_worker_c){ create(:user, :case_worker) }
  let!(:client){ create(:client, :accepted, users: [case_worker_a, case_worker_b]) }
  let!(:task){ create(:task, client: client) }
  context 'after_save' do
    context 'set_users' do
      it 'should have cases workers of the client it belongs to' do
        task.reload
        expect(task.users).to include(case_worker_a, case_worker_b)
        expect(task.users).not_to include(case_worker_c)
      end

      context 'when case workers of the client were changed, need to update its case workers too' do
        before do
          client.user_ids = [case_worker_a.id, case_worker_c.id]
          client.save
          task.reload
        end

        it 'should have new case workers of the client it belongs to' do
          task.reload
          expect(task.users).to include(case_worker_a, case_worker_c)
        end

        it 'should not have case workers who are not associated with its client anymore' do
          task.reload
          expect(task.users).not_to include(case_worker_b)
        end

        it 'case workers of its client should have it as their task' do
          expect(case_worker_a.case_worker_tasks.size).to eq(1)
          expect(case_worker_c.case_worker_tasks.size).to eq(1)
        end

        it 'case workers who are not associated with its client should not have it as their task' do
          expect(case_worker_b.case_worker_tasks.size).to eq(0)
        end
      end
    end
  end
end
