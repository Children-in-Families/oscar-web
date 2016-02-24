require 'rails_helper'

describe KinshipOrFosterCareCaseObserver do
  before :each do
    @observer  = KinshipOrFosterCareCaseObserver.instance
    @client    = stub_model(Client)
    @kinship_or_foster_care_case = stub_model(KinshipOrFosterCareCase, { client: @client })
  end

  describe 'observer' do
    before do
      @kinship_or_foster_care_case_observer = @observer.after_commit(@kinship_or_foster_care_case)
    end
    it 'should invoke after_commit method' do
      expect { @kinship_or_foster_care_case_observer }.not_to raise_error
    end
    it 'should invoke sidekiq after_commit' do
      expect(ClientWorker.jobs.size).to eq 1
    end
  end

  it 'should raise error with after_create method' do
    expect { @observer.after_create(@kinship_or_foster_care_case) }.to raise_error(NoMethodError)
  end
end
