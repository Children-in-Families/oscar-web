describe AdvancedSearches::ExitProgramFields, 'Method' do
  let!(:client)             { create(:client) }
  let!(:program_stream)     { create(:program_stream) }
  let!(:client_enrollment)  { create(:client_enrollment, client: client, program_stream: program_stream) }
  let!(:leave_program)      { create(:leave_program, client_enrollment: client_enrollment, program_stream: program_stream) }

  before do
    @exit_programs = AdvancedSearches::ExitProgramFields.new([program_stream.id]).render
    @fields = @exit_programs.last
  end

  context 'render' do
    it 'return field not nil' do
      expect(@exit_programs).not_to be_nil
    end

    it 'return all fields' do
      expect(@exit_programs.size).to equal 4
    end

    it 'return field with id' do
      expect(@fields[:id]).to include "exitprogram__#{program_stream.name}__age"
    end

    it 'return field with optGroup' do
      expect(@fields[:optgroup]).to include "#{program_stream.name} | Exit Program"
    end

    it 'return field with label' do
      expect(@fields[:label]).to include 'age'
    end

    it 'return field with exit_program Date' do
      exit_program_date = @exit_programs.first
      expect(exit_program_date[:label]).to include 'Exit Date'
    end
  end
end
