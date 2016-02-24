require 'rails_helper'

describe EmergencyCareCaseObserver do
  before :each do
    @observer             = EmergencyCareCaseObserver.instance
    @client               = stub_model(Client)
    @emergency_care_case  = stub_model(EmergencyCareCase, { client: @client })
  end

  describe 'observer' do
    before do
      @emergency_care_case_observer = @observer.after_commit(@emergency_care_case)
    end
    it 'should invoke after_commit method' do
      expect { @emergency_care_case_observer }.not_to raise_error
    end
    it 'should invoke sidekiq after_commit' do
      expect(ClientWorker.jobs.size).to eq 1
    end
  end

  it 'should raise error with after_create method' do
    expect { @observer.after_create(@emergency_care_case) }.to raise_error(NoMethodError)
  end
end