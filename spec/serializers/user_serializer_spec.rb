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

  it 'should be have attribute roles' do
    expect(serializer).to have_json_path('user/roles')
    expect(serializer).to have_json_type(String).at_path('user/roles')
  end

  it 'should be have attribute overdue_tasks' do
    expect(serializer).to have_json_path('user/overdue_tasks')
    expect(serializer).to have_json_type(Array).at_path('user/overdue_tasks')
  end

  it 'should be have attribute today_tasks' do
    expect(serializer).to have_json_path('user/today_tasks')
    expect(serializer).to have_json_type(Array).at_path('user/today_tasks')
  end

  it 'should be have attribute upcoming_tasks' do
    expect(serializer).to have_json_path('user/upcoming_tasks')
    expect(serializer).to have_json_type(Array).at_path('user/upcoming_tasks')
  end

end