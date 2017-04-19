require 'spec_helper'

describe ClientSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user) }
  let(:serializer) { ClientSerializer.new(client).to_json }

  it 'should be have attribute client as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('client')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('client/id')
    expect(serializer).to have_json_type(Integer).at_path('client/id')
  end

  it 'should be have attribute code' do
    expect(serializer).to have_json_path('client/code')
    expect(serializer).to have_json_type(String).at_path('client/code')
  end

  it 'should be have attribute given_name' do
    expect(serializer).to have_json_path('client/given_name')
    expect(serializer).to have_json_type(String).at_path('client/given_name')
  end

  it 'should be have attribute family_name' do
    expect(serializer).to have_json_path('client/family_name')
    expect(serializer).to have_json_type(String).at_path('client/family_name')
  end

  it 'should be have attribute gender' do
    expect(serializer).to have_json_path('client/gender')
    expect(serializer).to have_json_type(String).at_path('client/gender')
  end

  it 'should be have attribute date_of_birth' do
    expect(serializer).to have_json_path('client/date_of_birth')
    expect(serializer).to have_json_type(String).at_path('client/date_of_birth')
  end

  it 'should be have attribute status' do
    expect(serializer).to have_json_path('client/status')
    expect(serializer).to have_json_type(String).at_path('client/status')
  end

  it 'should be have attribute initial_referral_date' do
    expect(serializer).to have_json_path('client/initial_referral_date')
    expect(serializer).to have_json_type(NilClass).at_path('client/initial_referral_date')
  end

  it 'should be have attribute referral_phone' do
    expect(serializer).to have_json_path('client/referral_phone')
    expect(serializer).to have_json_type(String).at_path('client/referral_phone')
  end

  it 'should be have attribute follow_up_date' do
    expect(serializer).to have_json_path('client/follow_up_date')
    expect(serializer).to have_json_type(NilClass).at_path('client/follow_up_date')
  end

  it 'should be have attribute current_address' do
    expect(serializer).to have_json_path('client/current_address')
    expect(serializer).to have_json_type(String).at_path('client/current_address')
  end

  it 'should be have attribute able' do
    expect(serializer).to have_json_path('client/able')
    expect(serializer).to have_json_type(:boolean).at_path('client/able')
  end

  it 'should be have attribute reason_for_referral' do
    expect(serializer).to have_json_path('client/reason_for_referral')
    expect(serializer).to have_json_type(String).at_path('client/reason_for_referral')
  end

  it 'should be have attribute background' do
    expect(serializer).to have_json_path('client/background')
    expect(serializer).to have_json_type(String).at_path('client/background')
  end

  it 'should be have attribute user' do
    expect(serializer).to have_json_path('client/user')
    expect(serializer).to have_json_type(Object).at_path('client/user')
  end

  it 'should be have attribute birth_province' do
    expect(serializer).to have_json_path('client/birth_province')
    expect(serializer).to have_json_type(Object).at_path('client/birth_province')
  end

  it 'should be have attribute received_by' do
    expect(serializer).to have_json_path('client/received_by')
    expect(serializer).to have_json_type(Object).at_path('client/received_by')
  end

  it 'should be have attribute followed_up_by' do
    expect(serializer).to have_json_path('client/followed_up_by')
    expect(serializer).to have_json_type(Object).at_path('client/followed_up_by')
  end

  it 'should be have attribute referral_source' do
    expect(serializer).to have_json_path('client/referral_source')
    expect(serializer).to have_json_type(Object).at_path('client/referral_source')
  end

  it 'should be have attribute cases' do
    expect(serializer).to have_json_path('client/cases')
    expect(serializer).to have_json_type(Array).at_path('client/cases')
  end

  it 'should be have attribute name' do
    expect(serializer).to have_json_path('client/name')
    expect(serializer).to have_json_type(String).at_path('client/name')
  end

  it 'should be have attribute assessments' do
    expect(serializer).to have_json_path('client/assessments')
    expect(serializer).to have_json_type(Array).at_path('client/assessments')
  end

  it 'should be have attribute most_recent_case_note' do
    expect(serializer).to have_json_path('client/most_recent_case_note')
    expect(serializer).to have_json_type(NilClass).at_path('client/most_recent_case_note')
  end

  it 'should be have attribute next_appointment_date' do
    expect(serializer).to have_json_path('client/next_appointment_date')
    expect(serializer).to have_json_type(String).at_path('client/next_appointment_date')
  end

  it 'should be have attribute tasks' do
    expect(serializer).to have_json_path('client/tasks')
    expect(serializer).to have_json_type(Array).at_path('client/tasks')
  end
end
