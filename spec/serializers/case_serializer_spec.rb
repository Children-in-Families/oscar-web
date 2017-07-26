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

  it 'should be have attribute support_amount' do
    expect(serializer).to have_json_path('case/support_amount')
    expect(serializer).to have_json_type(Float).at_path('case/support_amount')
  end

  it 'should be have attribute support_note' do
    expect(serializer).to have_json_path('case/support_note')
    expect(serializer).to have_json_type(String).at_path('case/support_note')
  end

  it 'should be have attribute exited' do
    expect(serializer).to have_json_path('case/exited')
    expect(serializer).to have_json_type(:boolean).at_path('case/exited')
  end

  it 'should be have attribute exit_date' do
    expect(serializer).to have_json_path('case/exit_date')
    expect(serializer).to have_json_type(NilClass).at_path('case/exit_date')
  end

  it 'should be have attribute exit_note' do
    expect(serializer).to have_json_path('case/exit_note')
    expect(serializer).to have_json_type(String).at_path('case/exit_note')
  end

  it 'should be have attribute partner' do
    expect(serializer).to have_json_path('case/partner')
    expect(serializer).to have_json_type(Object).at_path('case/partner')
  end

  it 'should be have attribute province' do
    expect(serializer).to have_json_path('case/province')
    expect(serializer).to have_json_type(Object).at_path('case/province')
  end

  it 'should be have attribute created_at' do
    expect(serializer).to have_json_path('case/created_at')
    expect(serializer).to have_json_type(String).at_path('case/created_at')
  end

  it 'should be have attribute updated_at' do
    expect(serializer).to have_json_path('case/updated_at')
    expect(serializer).to have_json_type(String).at_path('case/updated_at')
  end

  it 'should be have attribute family_preservation' do
    expect(serializer).to have_json_path('case/family_preservation')
    expect(serializer).to have_json_type(:boolean).at_path('case/family_preservation')
  end

  it 'should be have attribute status' do
    expect(serializer).to have_json_path('case/status')
    expect(serializer).to have_json_type(String).at_path('case/status')
  end

  it 'should be have attribute case_length' do
    expect(serializer).to have_json_path('case/case_length')
    expect(serializer).to have_json_type(NilClass).at_path('case/case_length')
  end

  it 'should be have attribute case_conference_date' do
    expect(serializer).to have_json_path('case/case_conference_date')
    expect(serializer).to have_json_type(NilClass).at_path('case/case_conference_date')
  end

  it 'should be have attribute time_in_care' do
    expect(serializer).to have_json_path('case/time_in_care')
    expect(serializer).to have_json_type(NilClass).at_path('case/time_in_care')
  end

  it 'should be have attribute exited_from_cif' do
    expect(serializer).to have_json_path('case/exited_from_cif')
    expect(serializer).to have_json_type(:boolean).at_path('case/exited_from_cif')
  end

  it 'should be have attribute current' do
    expect(serializer).to have_json_path('case/current')
    expect(serializer).to have_json_type(:boolean).at_path('case/current')
  end
end