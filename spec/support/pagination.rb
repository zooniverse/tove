RSpec.shared_examples "pagination" do
  it 'respects page size' do
    get :index, params: { page: { size: 1 } }
    expect(json_data.size).to eql(1)
  end

  it 'respects page number' do
    get :index, params: { page: { number: 2, size: 1 } }
    expect(json_data.first["id"]).to eql(another.id.to_s)
  end

  it 'includes pagination metadata' do
    get :index
    expect(JSON.parse(response.body)['meta']).to include('pagination')
  end
end
