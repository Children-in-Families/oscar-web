# describe ClientBaseSqlBuilder, 'Method' do
#
#   context '#generate' do
#     it 'return client = query string' do
#       rules = [{id: "first_name", field: "first_name", type: "string",input: "text", operator: "equal", value: "Pirun"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.first_name = ?'
#       expect(filter_string[:values]).to include 'Pirun'
#     end
#
#     it 'return client != query string' do
#       rules = [{id: "first_name", field: "first_name", type: "string",input: "text", operator: "not_equal", value: "Pirun"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.first_name != ?'
#       expect(filter_string[:values]).to include 'Pirun'
#     end
#
#     it 'return client < query string' do
#       rules = [{id: "grade", field:"grade", type: "number", input: "text", operator: "less", value: "12"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.grade < ?'
#       expect(filter_string[:values]).to include '12'
#     end
#
#     it 'return client <= query string' do
#       rules = [{id: "grade", field:"grade", type: "number", input: "text", operator: "less_or_equal",value: "12"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.grade <= ?'
#       expect(filter_string[:values]).to include '12'
#     end
#
#     it 'return client > query string' do
#       rules = [{id: "grade", field:"grade", type: "number", input: "text", operator: "greater", value: "12"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.grade > ?'
#       expect(filter_string[:values]).to include '12'
#     end
#
#     it 'return client >= query string' do
#       rules = [{id: "grade", field:"grade", type: "number", input: "text", operator: "greater_or_equal",value: "12"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.grade >= ?'
#       expect(filter_string[:values]).to include '12'
#     end
#
#     it 'return client ILIKE query string' do
#       rules = [{id: "first_name", field:"first_name", type: "string", input: "text", operator: "contains", value: "Pirun"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.first_name ILIKE ?'
#       expect(filter_string[:values]).to include '%Pirun%'
#     end
#
#     it 'return client NOT ILIKE query string' do
#       rules = [{id: "first_name", field:"first_name", type: "string", input: "text", operator: "not_contains", value: "Pirun"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.first_name NOT ILIKE ?'
#       expect(filter_string[:values]).to include '%Pirun%'
#     end
#
#     it 'return client IS NULL query string' do
#       rules = [{id: "first_name", field:"first_name", type: "string", input: "text", operator: "is_empty", value: "Pirun"}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.first_name IS NULL'
#       expect(filter_string[:values]).to include
#     end
#
#     it 'return client BETWEEN query string' do
#       rules = [{id: "grade", field:"grade", type: "number", input: "text", operator: "between", value: ['0', '12']}]
#       filter_string = ClientBaseSqlBuilder.generate(Client.all, rules)
#       expect(filter_string[:sql_string]).to include 'clients.grade BETWEEN ? AND ?'
#       expect(filter_string[:values]).to include '0', '12'
#     end
#   end
# end
