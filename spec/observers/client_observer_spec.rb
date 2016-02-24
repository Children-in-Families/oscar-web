require 'rails_helper'

describe ClientObserver do
  before :each do
    @observer  = ClientObserver.instance
    @client    = stub_model(Client)
  end

  describe 'observer' do
    before do
      @client_observer = @observer.after_commit(@client)
    end
    it 'should invoke after_commit method' do
      expect { @client_observer }.not_to raise_error
    end
    it 'should invoke sidekiq after_commit' do
      expect(ClientWorker.jobs.size).to eq 1
    end
  end

  it 'should raise error with after_create method' do
    expect { @observer.after_create(@client) }.to raise_error(NoMethodError)
  end
end
