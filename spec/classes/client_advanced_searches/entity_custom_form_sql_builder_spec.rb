describe AdvancedSearches::EntityCustomFormSqlBuilder, 'Method' do
  fields = [{"name"=>"checkbox-group-1499057633702", "type"=>"checkbox-group", "label"=>"Health check", "values"=>[{"label"=>"Excellent", "value"=>"Excellent", "selected"=>true}, {"label"=>"Good", "value"=>"Good"}, {"label"=>"Bad", "value"=>"Bad"}], "className"=>"checkbox-group"}, {"name"=>"number-1499057693908", "type"=>"number", "label"=>"Age", "className"=>"form-control"}, {"name"=>"text-1499057762900", "type"=>"text", "label"=>"Discription", "subtype"=>"text", "className"=>"form-control"}, {"name"=>"date-1499057826083", "type"=>"date", "label"=>"Start Date", "className"=>"calendar"}]

  properties = {"Age"=>"12", "Start Date"=>"2017-07-03", "Discription"=>"Testing 1", "Health check"=>["Excellent"]}.to_json

  let!(:custom_form) { create(:custom_field, fields: fields) }
  let!(:client) { create(:client) }
  let!(:custom_field_property) { create(:custom_field_property, properties: properties, custom_formable_id: client.id, custom_field: custom_form) }

  context '#generate' do
    it 'return client = query string' do
      rules = {'id' => "Discription", 'field' => "formbuilder_#{custom_form.form_title}_Discription", 'type'=> "string", 'input'=> "text", 'operator'=> "equal", 'value'=> "Testing 1"}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form.id, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end

    it 'return client != query string' do
      rules = {'id' => "Discription", 'field' => "formbuilder_#{custom_form.form_title}_Discription", 'type' => "string", 'input' => "text", 'operator' => "not_equal", 'value' => "Testing"}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form.id, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end

    it 'return client < query string' do
      rules = {'id' => "Age", 'field' => "formbuilder_#{custom_form.form_title}_Age", 'type' => "number", 'input' => "text", 'operator' => "less", 'value' => "13"}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end

    it 'return client <= query string' do
      rules = {'id' => "Age", 'field' => "formbuilder_#{custom_form.form_title}_Age", 'type' => "number", 'input' => "text", 'operator' => "less_or_equal", 'value' => "12"}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end

    it 'return client > query string' do
      rules = {'id' => "Age", 'field' => "formbuilder_#{custom_form.form_title}_Age", 'type' => "number", 'input' => "text", 'operator' => "greater", 'value' => "11"}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end

    it 'return client >= query string' do
      rules = {'id' => "Age", 'field' => "formbuilder_#{custom_form.form_title}_Age", 'type' => "number", 'input' => "text", 'operator' => "greater_or_equal", 'value' => "11"}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end

    it 'return client ILIKE query string' do
      rules = {'id' => "Age", 'field' => "formbuilder_#{custom_form.form_title}_Age", 'type' => "number", 'input' => "text", 'operator' => "greater_or_equal", 'value' => "11"}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end

    it 'return client NOT ILIKE query string' do
      rules = {'id' => "Discription", 'field' => "formbuilder_#{custom_form.form_title}_Discription", 'type' => "string", 'input' => "text", 'operator' => "not_contains", 'value' => "My Name"}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form.id, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end

    it 'return client IS NULL query string' do
      rules = {'id' => "Discription", 'field' => "formbuilder_#{custom_form.form_title}_Discription", 'type' => "string", 'input' => "text", 'operator' => "is_empty", 'value' => ""}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form.id, rules, 'client').get_sql
      expect(filter_string[:id]).to include ''
      expect(filter_string[:values]).to eq([])
    end

    it 'return client BETWEEN query string' do
      rules = {'id' => "Age", 'field' => "Age", 'type' => "formbuilder_#{custom_form.form_title}_number", 'input' => "text", 'operator' => "between", 'value' => ['0', '12']}
      filter_string = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form.id, rules, 'client').get_sql
      expect(filter_string[:id]).to include 'clients.id IN (?)'
      expect(filter_string[:values]).to include(client.id)
    end
  end
end
