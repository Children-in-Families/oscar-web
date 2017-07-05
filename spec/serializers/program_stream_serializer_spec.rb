require 'spec_helper'

describe ProgramStreamSerializer, type: :serializer do
  let(:program_stream)  { create(:program_stream) }
  let!(:tracking)       { create(:tracking, program_stream: program_stream)}
  let(:serializer)      { ProgramStreamSerializer.new(program_stream).to_json }

  it 'should be have attribute program_stream as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('program_stream')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('program_stream/id')
    expect(serializer).to have_json_type(Integer).at_path('program_stream/id')
  end

  it 'should be have attribute name' do
    expect(serializer).to have_json_path('program_stream/name')
    expect(serializer).to have_json_type(String).at_path('program_stream/name')
  end

  it 'should be have attribute description' do
    expect(serializer).to have_json_path('program_stream/description')
    expect(serializer).to have_json_type(NilClass).at_path('program_stream/description')
  end

  it 'should be have attribute rules' do
    expect(serializer).to have_json_path('program_stream/rules')
    expect(serializer).to have_json_type(Object).at_path('program_stream/rules')
  end

  it 'should be have attribute enrollment' do
    expect(serializer).to have_json_path('program_stream/enrollment')
    expect(serializer).to have_json_type(Object).at_path('program_stream/enrollment')
  end

  it 'should be have attribute exit_program' do
    expect(serializer).to have_json_path('program_stream/exit_program')
    expect(serializer).to have_json_type(Object).at_path('program_stream/exit_program')
  end

  it 'should be have attribute quantity' do
    expect(serializer).to have_json_path('program_stream/quantity')
    expect(serializer).to have_json_type(Integer).at_path('program_stream/quantity')
  end
end
