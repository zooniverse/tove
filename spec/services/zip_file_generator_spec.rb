RSpec.describe ZipFileGenerator do
  let(:zip_file_path) { Rails.root.join("spec/fixtures/files/test-zip.zip") }

  describe '#write' do
    context 'when given a multi-level directory' do
      let(:zip_generator) {
        described_class.new(Rails.root.join("spec/fixtures"), zip_file_path)
      }

      it 'generates a zip file' do
        zip_generator.write
        expect(File).to exist(zip_file_path)
        File.delete(zip_file_path)
      end
    end
  end
end
