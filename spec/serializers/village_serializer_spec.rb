describe VillageSerializer, type: :serializer do
  let(:village) { create(:village) }
  let(:serializer) { VillageSerializer.new(village).to_json }

  it 'village attribute as root path' do
    expect(serializer).to have_json_size(1)
    expect(serializer).to have_json_type(Object).at_path('village')
  end

  it 'id attribute' do
    expect(serializer).to have_json_path('village/id')
    expect(serializer).to have_json_type(Integer).at_path('village/id')
  end

  it 'code attribute' do
    expect(serializer).to have_json_path('village/code')
    expect(serializer).to have_json_type(String).at_path('village/code')
  end

  it 'code_format attribute' do
    expect(serializer).to have_json_path('village/code_format')
    expect(serializer).to have_json_type(String).at_path('village/code_format')
  end
end
