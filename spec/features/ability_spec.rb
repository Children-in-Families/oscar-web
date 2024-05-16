xdescribe 'Abilities' do
  subject(:ability) { Ability.new(user) }

  context 'admin permissions' do
    let!(:user) { create(:user, :admin) }

    it 'can manage All' do
      should be_able_to(:manage, :all)
    end
  end

  context 'manager permissions' do
    let!(:user_2) { create(:user, :manager, id: 2) }
    let!(:user) { create(:user, :manager, id: 1, manager_ids: [1, 2]) }

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

    xit 'can manage Client' do
      should be_able_to(:create, Client)
      field = '"case_worker_clients"."user_id"'
      value = user.all_subordinates.ids.first
      expect(ability.model_adapter(Client, :manage).conditions).to include("#{field} = #{value}")
    end

    it 'can manage User' do
      field = '"users"."id"'
      user_2.update(manager_id: user.id)
      value = User.where('manager_ids && ARRAY[?]', user.id).map(&:id).first
      ability.model_adapter(User, :manage).conditions.should == %Q[(#{field} = #{user.id}) OR (#{field} = #{value || 0})]
    end

    it 'can manage Case' do
      should be_able_to(:manage, Case)
    end

    it 'can create Task' do
      should be_able_to(:create, Task)
    end

    it 'can read Task' do
      should be_able_to(:read, Task)
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
      field = '"custom_field_properties"."custom_formable_type"'
      ability.model_adapter(CustomFieldProperty, :manage).conditions.should == %Q[(#{field} = 'Partner') OR ((#{field} = 'Family') OR (#{field} = 'Client'))]
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
  end

  context 'case worker permissions' do
    let!(:user) { create(:user, :case_worker) }

    it 'can create family' do
      should be_able_to(:create, Family)
    end

    it 'can create Task' do
      should be_able_to(:create, Task)
    end

    it 'can read Task' do
      should be_able_to(:read, Task)
    end

    context 'with familiy and clients' do
      let!(:client) { create(:client, user_ids: [user.id]) }
      let!(:family) { create(:family, children: [client.id]) }

      it 'can manage family of their clients' do
        ability.model_adapter(Family, :manage).conditions.should == { id: [family.id] }
      end
    end
  end
end
