require 'spec_helper'

describe CaseSerializer, type: :serializer do
  let(:client_case) { create(:case)}
  let(:serializer) { CaseSerializer.new(client_case).to_json }

  it 'should be have attribute case as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('case')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('case/id')
    expect(serializer).to have_json_type(Integer).at_path('case/id')
  end

  it 'should be have attribute start_date' do
    expect(serializer).to have_json_path('case/start_date')
    expect(serializer).to have_json_type(String).at_path('case/start_date')
  end

  it 'should be have attribute carer_names' do
    expect(serializer).to have_json_path('case/carer_names')
    expect(serializer).to have_json_type(String).at_path('case/carer_names')
  end

  it 'should be have attribute carer_address' do
    expect(serializer).to have_json_path('case/carer_address')
    expect(serializer).to have_json_type(String).at_path('case/carer_address')
  end

  it 'should be have attribute carer_phone_number' do
    expect(serializer).to have_json_path('case/carer_phone_number')
    expect(serializer).to have_json_type(String).at_path('case/carer_phone_number')
  end

  it 'should be have attribute case_type' do
    expect(serializer).to have_json_path('case/case_type')
    expect(serializer).to have_json_type(String).at_path('case/case_type')
  end

  it 'should be have attribute placement_date' do
    expect(serializer).to have_json_path('case/placement_date')
    expect(serializer).to have_json_type(NilClass).at_path('case/placement_date')
  end

  it 'should be have attribute initial_assessment_date' do
    expect(serializer).to have_json_path('case/initial_assessment_date')
    expect(serializer).to have_json_type(NilClass).at_path('case/initial_assessment_date')
  end

  it 'should be have attribute family' do
    expect(serializer).to have_json_path('case/family')
    expect(serializer).to have_json_type(Object).at_path('case/family')
  end
end
