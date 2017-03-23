describe BaseFilters, 'Method' do
  let!(:client) { create(:client, first_name: 'pitou', code: 1000) }
  let!(:client_2) { create(:client, first_name: 'test1', code: 2000) }
  let!(:client_3) { create(:client, first_name: 'test2', code: 2010) }
  let!(:client_4) { create(:client, first_name: 'test3', code: 2020) }

  before do
    @filter = BaseFilters.new(Client.all)
  end

  context 'is' do
    it 'return record exactly with filter' do
      filter = @filter.is('clients', 'first_name', client.first_name)
      expect(filter.size).to equal 1
    end
  end

  context 'is_not' do
    it 'return records that not in filter' do
      filter = @filter.is_not('clients', 'first_name', client.first_name)
      expect(filter.size).to equal 3
    end
  end

  context 'less' do
    it 'return records that less than 2010 (field code)' do
      filter = @filter.less('clients', 'code', '2010')
      expect(filter.size).to equal 2
    end
  end

  context 'less_or_equal' do
    it 'return records that less or equal than 2010 (field code)' do
      filter = @filter.less_or_equal('clients', 'code', '2010')
      expect(filter.size).to equal 3
    end
  end

  context 'greater' do
    it 'return records that greater than 2010 (field code)' do
      filter = @filter.greater('clients', 'code', '2010')
      expect(filter.size).to equal 1
    end
  end

  context 'greater_or_equal' do
    it 'return records that greater or equal than 2010 (field code)' do
      filter = @filter.greater_or_equal('clients', 'code', '2010')
      expect(filter.size).to equal 2
    end
  end

  context 'contains' do
    it 'return records that contains like filter' do
      filter = @filter.contains('clients', 'first_name', client.first_name)
      expect(filter.size).to equal 1
    end
  end

  context 'not_contains' do
    it 'return records that contains not like filter' do
      filter = @filter.not_contains('clients', 'first_name', client.first_name)
      expect(filter.size).to equal 3
    end
  end

  context 'range_between' do
    it 'return records between 2001 and 2010' do
      filter = @filter.range_between('clients', 'code', ['2001', '2010'])
      expect(filter.size).to equal 1
    end
  end
end