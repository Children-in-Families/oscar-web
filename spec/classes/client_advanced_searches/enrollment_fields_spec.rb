describe AdvancedSearches::EnrollmentFields, 'Method' do
  let!(:client)             { create(:client) }
  let!(:program_stream)     { create(:program_stream) }
  let!(:client_enrollment)  { create(:client_enrollment, client: client, program_stream: program_stream) }

  before do
    @enrollment = AdvancedSearches::EnrollmentFields.new([program_stream.id]).render
    @fields = @enrollment.last
  end

  context 'render' do
    it 'return field not nil' do
      expect(@enrollment).not_to be_nil
    end

    it 'return all fields' do
      expect(@enrollment.size).to equal 4
    end

    it 'return field with id' do
      expect(@fields[:id]).to include "enrollment__#{program_stream.name}__age"
    end

    it 'return field with optGroup' do
      expect(@fields[:optgroup]).to include "#{program_stream.name} | Enrollment"
    end

    it 'return field with label' do
      expect(@fields[:label]).to include 'age'
    end

    it 'return field with Enrollment Date' do
      enrollment_date = @enrollment.first
      expect(enrollment_date[:label]).to include 'Enrollment Date'
    end
  end
end
