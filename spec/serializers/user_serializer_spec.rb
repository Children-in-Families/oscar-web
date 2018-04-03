require 'spec_helper'

RSpec.describe UserSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:serializer) { UserSerializer.new(user).to_json }

  it 'should be have attribute users as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('user')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('user/id')
    expect(serializer).to have_json_type(Integer).at_path('user/id')
  end

  it 'should be have attribute first_name' do
    expect(serializer).to have_json_path('user/first_name')
    expect(serializer).to have_json_type(String).at_path('user/first_name')
  end

  it 'should be have attribute last_name' do
    expect(serializer).to have_json_path('user/last_name')
    expect(serializer).to have_json_type(String).at_path('user/last_name')
  end

  it 'should be have attribute email' do
    expect(serializer).to have_json_path('user/email')
    expect(serializer).to have_json_type(String).at_path('user/email')
  end

  it 'should be have attribute roles' do
    expect(serializer).to have_json_path('user/roles')
    expect(serializer).to have_json_type(String).at_path('user/roles')
  end

  it 'should be have attribute mobile' do
    expect(serializer).to have_json_path('user/mobile')
    expect(serializer).to have_json_type(String).at_path('user/mobile')
  end

  it 'should be have attribute date_of_birth' do
    expect(serializer).to have_json_path('user/date_of_birth')
    expect(serializer).to have_json_type(NilClass).at_path('user/date_of_birth')
  end

  it 'should be have attribute archived' do
    expect(serializer).to have_json_path('user/archived')
    expect(serializer).to have_json_type(:boolean).at_path('user/archived')
  end

  it 'should be have attribute admin' do
    expect(serializer).to have_json_path('user/admin')
    expect(serializer).to have_json_type(:boolean).at_path('user/admin')
  end

  it 'should be have attribute manager_id' do
    expect(serializer).to have_json_path('user/manager_id')
    expect(serializer).to have_json_type(NilClass).at_path('user/manager_id')
  end

  it 'should be have attribute pin_code' do
    expect(serializer).to have_json_path('user/pin_code')
    expect(serializer).to have_json_type(String).at_path('user/pin_code')
  end

  it 'should be have attribute clients' do
    expect(serializer).to have_json_path('user/clients')
    expect(serializer).to have_json_type(Array).at_path('user/clients')
  end
end
