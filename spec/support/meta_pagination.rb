RSpec.shared_examples "meta pagination" do |private_test=true|
  it 'should contain page information' do
    get :index
    expect(JSON.parse(response.body)['meta']).to include('pagination')
  end
end
