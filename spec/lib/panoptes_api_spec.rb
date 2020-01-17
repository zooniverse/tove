require './spec/fixtures/project_roles.rb'
require './spec/fixtures/project.rb'

RSpec.describe PanoptesApi, type: :lib do
  include_context 'role parsing'
  include_context 'project parsing'

  let(:panoptes_api) { described_class.new(123) }
  let(:client_double) { double }

  it 'aliases the API endpoint' do
    expect(panoptes_api.api).to be_a Panoptes::Endpoints::JsonApiEndpoint
  end

  describe '#token_created_at' do
    let(:party_time) { Time.parse('1999-01-01') }

    before do
      allow(panoptes_api).to receive(:token_expiry).and_return(party_time)
    end

    it 'returns two hours before the token expires' do
      ENV["TOKEN_VALIDITY_TIME"] = nil
      expect(panoptes_api.token_created_at).to eq(party_time - 2.hours)
    end

    it 'uses the expiration time env var if present' do
      ENV["TOKEN_VALIDITY_TIME"] = "24"
      expect(panoptes_api.token_created_at).to eq(party_time - 24.hours)
    end
  end

  describe '#roles' do
    let(:parsed_roles) { { '1' => ["collaborator"], '2' => ["owner"], '3' => ["researcher"] } }

    it 'returns a hash' do
      allow(panoptes_api).to receive(:api).and_return(client_double)
      allow(client_double).to receive(:paginate).and_return(raw_roles.with_indifferent_access)
      expect(panoptes_api.roles(123)).to eq(parsed_roles)
    end
  end

  describe '#project' do
    let(:parsed_project) { { :id => 1715, :slug => "zwolf/ztest"} }

    it 'returns a hash' do
      allow(panoptes_api).to receive(:api).and_return(client_double)
      allow(client_double).to receive(:get).and_return(raw_project.with_indifferent_access)
      expect(panoptes_api.project('slug')).to eq(parsed_project)
    end
  end

end