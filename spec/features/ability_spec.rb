describe 'able screening question' do
  subject(:ability){ Ability.new(user) }

  context "login as admin" do
    let!(:user) { create(:user, :admin) }
    it 'should be able to manage' do
      should be_able_to(:manage, AbleScreeningQuestion.new)
    end
  end

  context "login as manager" do
    let!(:user) { create(:user, :manager) }
    it 'should be able to manage' do
      should be_able_to(:manage, AbleScreeningQuestion.new)
    end
  end

  context "login as kc manager" do
    let!(:user) { create(:user, :kc_manager) }
    it 'should be able to manage' do
      should_not be_able_to(:manage, AbleScreeningQuestion.new)
    end
  end

  context "login as fc manager" do
    let!(:user) { create(:user, :fc_manager) }
    it 'should be able to manage' do
      should_not be_able_to(:manage, AbleScreeningQuestion.new)
    end
  end

  context "login as ec manager" do
    let!(:user) { create(:user, :ec_manager) }
    it 'should be able to manage' do
     should_not be_able_to(:manage, AbleScreeningQuestion.new)
    end
  end

  context "login as able manager" do
    let!(:user) { create(:user, :able_manager) }
    it 'should be able to manage' do
      should be_able_to(:manage, AbleScreeningQuestion.new)
    end
  end

  context "login as strategic overviewer" do
    let!(:user) { create(:user, :strategic_overviewer) }
    it 'should be able to manage' do
      should_not be_able_to(:manage, AbleScreeningQuestion.new)
    end
    it 'should be able to manage' do
      should be_able_to(:read, AbleScreeningQuestion.new)
    end
  end


  context "login as case worker" do
    let!(:user) { create(:user, :case_worker) }
    it 'should be able to manage' do
      should be_able_to(:manage, AbleScreeningQuestion.new)
    end
  end
end

describe 'Family' do
  subject(:ability){ Ability.new(user) }

  context 'login as admin' do
    let!(:user){ create(:user, :admin) }
    it 'should be able to manage' do
      should be_able_to(:manage, Family.new)
    end
  end

  context 'login as manager' do
    let!(:user){ create(:user, :manager) }
    it 'should be able to manage' do
      should be_able_to(:manage, Family.new)
    end
  end

  context 'login as ec manage' do
    let!(:user){ create(:user, :ec_manager) }
    it 'should be able to manage' do
      should be_able_to(:manage, Family.new)
    end
  end

  context 'login as fc manage' do
    let!(:user){ create(:user, :fc_manager) }
    it 'should be able to manage' do
      should be_able_to(:manage, Family.new)
    end
  end

  context 'login as kc manage' do
    let!(:user){ create(:user, :kc_manager) }
    it 'should be able to manage' do
      should be_able_to(:manage, Family.new)
    end
  end

  context 'login as able manager' do
    let!(:user){ create(:user, :able_manager) }
    it 'should be able to manage' do
      should_not be_able_to(:manage, Family.new)
    end
  end

  context 'login as strategic overviewer' do
    let!(:user){ create(:user, :strategic_overviewer) }
    it 'should be able to manage' do
     should be_able_to(:read, Family.new)
    end
    it 'should be able to manage' do
      should_not be_able_to(:manage, Family.new)
    end
  end

  context 'login as case worker' do
    let!(:user){ create(:user, :case_worker) }
    it 'should be able to manage' do
      should_not be_able_to(:manage, Family.new)
    end
  end
end
