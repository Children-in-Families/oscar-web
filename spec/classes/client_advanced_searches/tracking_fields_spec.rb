describe AdvancedSearches::TrackingFields, 'Method' do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  let!(:client)             { create(:client) }
  let!(:program_stream)     { create(:program_stream) }
  let!(:tracking)           { create(:tracking, program_stream: program_stream) }
  let!(:client_enrollment)  { create(:client_enrollment, client: client, program_stream: program_stream) }

  before do
    @tracking_fields = AdvancedSearches::TrackingFields.new([program_stream.id]).render
    @fields = @tracking_fields.last
  end

  context 'render' do
    it 'return field not nil' do
      expect(@tracking_fields).not_to be_nil
    end

    it 'return all fields' do
      expect(@tracking_fields.size).to equal 3
    end

    it 'return field with id' do
      tracking = program_stream.trackings.first
      expect(@fields[:id]).to include "tracking__#{program_stream.name}__#{tracking.name}__age"
    end

    it 'return field with optGroup' do
      tracking = program_stream.trackings.first
      expect(@fields[:optgroup]).to include "#{program_stream.name} | #{tracking.name} | Tracking"
    end

    it 'return field with label' do
      expect(@fields[:label]).to include 'age'
    end
  end
end
