describe AdvancedSearches::ClientAdvancedSearch, 'Method' do
  let!(:client)   { create(:client, given_name: 'test', code: 1000)  }
  let!(:client_2) { create(:client, given_name: 'test', code: 2000)  }
  let!(:client_3) { create(:client, given_name: 'test', code: 2010)  }
  let!(:client_4) { create(:client, given_name: 'test3', code: 2020) }

  it 'return clients that has name test and code greater than 2000' do
    rules = {condition: "AND", rules:
      [
        {:id=>"given_name", :field=>"given_name", :type=>"string", :input=>"text", :operator=>"equal", :value=>"test"},
        {:id=>"code", :field=>"code", :type=>"integer", :input=>"text", :operator=>"greater", :value=>"1000"}
      ]
    }
    clients = AdvancedSearches::ClientAdvancedSearch.new(rules, Client.all).filter

    expect(clients).to include(client_2, client_3)
  end

  it 'return clients that has name test or code greater than 100' do
    rules = {condition: "OR", rules:
      [
        {:id=>"given_name", :field=>"given_name", :type=>"string", :input=>"text", :operator=>"equal", :value=>"test"},
        {:id=>"code", :field=>"code", :type=>"integer", :input=>"text", :operator=>"greater", :value=>"100"}
      ]
    }
    clients = AdvancedSearches::ClientAdvancedSearch.new(rules, Client.all).filter
    expect(clients).to include(client, client_2, client_3, client_4)
  end
end
