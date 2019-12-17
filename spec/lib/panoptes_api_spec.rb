require './spec/fixtures/project_roles.rb'
require './spec/fixtures/project.rb'

RSpec.describe PanoptesApi, type: :lib do
  include_context 'role parsing'
  include_context 'project parsing'

  let(:panoptes_api) { described_class.new(123) }
  let(:client_double) { double }

  before do
    allow(panoptes_api).to receive(:api).and_return(client_double)
  end

  describe '#roles' do
    let(:parsed_roles) { { 1 => ["collaborator"], 2 => ["owner"], 3 => ["researcher"] } }

    it 'should return a hash' do
      allow(client_double).to receive(:paginate).and_return(raw_roles.with_indifferent_access)
      expect(panoptes_api.roles(123)).to eq(parsed_roles)
    end
  end

  describe '#project' do
    let(:parsed_project) { { :id => 1715, :slug => "zwolf/ztest"} }

    it 'should return a hash' do
      allow(client_double).to receive(:get).and_return(raw_project.with_indifferent_access)
      expect(panoptes_api.project('slug')).to eq(parsed_project)
    end
  end

end