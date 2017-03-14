describe Task, 'associations' do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:domain)}
  it { is_expected.to belong_to(:case_note_domain_group)}
  it { is_expected.to belong_to(:client)}
end

describe Task, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:domain) }
  it { is_expected.to validate_presence_of(:completion_date) }
end

describe Task, 'scopes' do
  let!(:domain){ create(:domain)}
  let!(:task){ create(:task, domain: domain)}
  let!(:task_other){ create(:task)}
  let!(:completed_task){ create(:task, completed: true) }
  let!(:incomplete_task){ create(:task, completed: false) }
  let!(:overdue_task){ create(:task, completion_date: Date.today - 1.month) }
  let!(:today_task){ create(:task, completion_date: Date.today) }
  let!(:upcoming_task){ create(:task, completion_date: Date.today + 1.month) }

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
  let!(:client) { create(:client) }
  let!(:other_client) { create(:client) }
  let!(:task){ create(:task, user: user, client: client) }
  let!(:other_task){ create(:task, user: other_user, client: other_client) }

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
end
