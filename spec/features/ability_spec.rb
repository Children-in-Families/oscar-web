describe 'Abilities' do
  subject(:ability){ Ability.new(user) }

  context 'admin permissions' do
    let!(:user){ create(:user, :admin) }

    it 'can manage All' do
      should be_able_to(:manage, :all)
    end
  end

  context 'manager permissions' do
    let!(:user){ create(:user, :manager) }

    it 'can manage Agency' do
      should be_able_to(:manage, Agency)
    end

    it 'can manage ReferralSource' do
      should be_able_to(:manage, ReferralSource)
    end

    it 'can manage QuarterlyReport' do
      should be_able_to(:manage, QuarterlyReport)
    end

    it 'can manage ProgramStream' do
      should be_able_to(:read, ProgramStream)
      should be_able_to(:preview, ProgramStream)
    end

    it 'can manage AbleScreeningQuestion' do
      should be_able_to(:manage, AbleScreeningQuestion)
    end

    it 'can manage Client' do
      should be_able_to(:create, Client)
      should be_able_to(:manage, Client, case_worker_clients: { user_id: User.where('manager_ids && ARRAY[:user_id] OR id = :user_id', { user_id: user.id }).map(&:id) })
    end

    it 'can manage User' do
      should be_able_to(:manage, User, id: User.where('manager_ids && ARRAY[?]', user.id).map(&:id))
      should be_able_to(:manage, User, id: user.id)
    end

    it 'can manage Case' do
      should be_able_to(:manage, Case)
    end

    it 'can manage Task' do
      should be_able_to(:manage, Task)
    end

    it 'can manage Assessment' do
      should be_able_to(:manage, Assessment)
    end

    it 'can manage CaseNote' do
      should be_able_to(:manage, CaseNote)
    end

    it 'can manage Family' do
      should be_able_to(:manage, Family)
    end

    it 'can manage Partner' do
      should be_able_to(:manage, Partner)
    end

    it 'can manage CustomFieldProperty' do
      should be_able_to(:manage, CustomFieldProperty, custom_formable_type: 'Client')
      should be_able_to(:manage, CustomFieldProperty, custom_formable_type: 'Family')
      should be_able_to(:manage, CustomFieldProperty, custom_formable_type: 'Partner')
    end

    it 'can manage CustomField' do
      should be_able_to(:manage, CustomField)
    end

    it 'can manage ClientEnrollment' do
      should be_able_to(:manage, ClientEnrollment)
    end

    it 'can manage ClientEnrollmentTracking' do
      should be_able_to(:manage, ClientEnrollmentTracking)
    end

    it 'can manage LeaveProgram' do
      should be_able_to(:manage, LeaveProgram)
    end

    it 'can read ProgressNote' do
      should be_able_to(:read, ProgressNote)
    end
  end
end
