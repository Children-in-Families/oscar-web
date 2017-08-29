describe AdvancedSearches::FilterTypes, 'Method' do
  context '#text_options' do
    text_options = AdvancedSearches::FilterTypes.text_options('given_name', 'Given Name', 'Client Basic Fields')

    it 'return configuration object with id' do
      expect(text_options[:id]).to eq 'given_name'
    end

    it 'return configuration object with label' do
      expect(text_options[:label]).to eq 'Given Name'
    end

    it 'return configuration object with type' do
      expect(text_options[:type]).to eq 'string'
    end

    it 'return configuration object with operator' do
      operators = ['equal', 'not_equal', 'contains', 'not_contains', 'is_empty', 'is_not_empty']
      expect(text_options[:operators]).to eq operators
    end
  end

  context '#number_options' do
    number_options = AdvancedSearches::FilterTypes.number_options('code', 'Code', 'Client Basic Fields')

    it 'return configuration object with id' do
      expect(number_options[:id]).to eq 'code'
    end

    it 'return configuration object with label' do
      expect(number_options[:label]).to eq 'Code'
    end

    it 'return configuration object with type' do
      expect(number_options[:type]).to eq 'integer'
    end

    it 'return configuration object with operator' do
      operators = ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty']
      expect(number_options[:operators]).to eq operators
    end
  end

  context '#drop_list_options' do
    drop_list_options = AdvancedSearches::FilterTypes.drop_list_options('gender', 'Gender', {male: 'Male', female: 'Female'}, 'Client Basic Fields')

    it 'return configuration object with id' do
      expect(drop_list_options[:id]).to eq 'gender'
    end

    it 'return configuration object with label' do
      expect(drop_list_options[:label]).to eq 'Gender'
    end

    it 'return configuration object with values' do
      values = {male: 'Male', female: 'Female'}
      expect(drop_list_options[:values]).to eq values
    end

    it 'return configuration object with type' do
      expect(drop_list_options[:type]).to eq 'string'
    end

    it 'return configuration object with input' do
      expect(drop_list_options[:input]).to eq 'select'
    end

    it 'return configuration object with operator' do
      operators = ['equal', 'not_equal', 'is_empty', 'is_not_empty']
      expect(drop_list_options[:operators]).to eq operators
    end
  end

  context '#date_picker_options' do
    date_picker_options = AdvancedSearches::FilterTypes.date_picker_options('date_of_birth', 'Date of Birth', 'Client Basic Fields')

    it 'return configuration object with id' do
      expect(date_picker_options[:id]).to eq 'date_of_birth'
    end

    it 'return configuration object with label' do
      expect(date_picker_options[:label]).to eq 'Date of Birth'
    end

    it 'return configuration object with type' do
      expect(date_picker_options[:type]).to eq 'date'
    end

    it 'return configuration object with operator' do
      operators = ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty']
      expect(date_picker_options[:operators]).to eq operators
    end
  end
end
