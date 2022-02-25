require 'spec_helper'

RSpec.describe TaskSerializer, type: :serializer do
  let(:task) { create(:task) }
  let(:serializer) { TaskSerializer.new(task).to_json }

  it 'should be have attribute task as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('task')
  end

  it 'should be have attribute id' do
    expect(serializer).to have_json_path('task/id')
    expect(serializer).to have_json_type(Integer).at_path('task/id')
  end

  it 'should be have attribute name' do
    expect(serializer).to have_json_path('task/name')
    expect(serializer).to have_json_type(String).at_path('task/name')
  end

  it 'should be have attribute expected_date' do
    expect(serializer).to have_json_path('task/expected_date')
    expect(serializer).to have_json_type(String).at_path('task/expected_date')
  end

  it 'should be have attribute domain' do
    expect(serializer).to have_json_path('task/domain')
    expect(serializer).to have_json_type(Object).at_path('task/domain')
  end

  it 'should be have attribute completed' do
    expect(serializer).to have_json_path('task/completed')
    expect(serializer).to have_json_type(:boolean).at_path('task/completed')
  end
end
