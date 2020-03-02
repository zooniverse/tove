class Transcription < ApplicationRecord
  belongs_to :workflow
  has_many_attached :files

  validates :status, presence: true
  validates :group_id, presence: true
  validate :text_json_is_not_nil

  enum status: {
    approved: 0,
    in_progress: 1,
    ready: 2, # ready as in "ready for approval"
    unseen: 3
  }

  def upload_files_to_storage
    file_generator = DataExports::TranscriptionFileGenerator.new(self)
    file_generator.generate_transcription_files.each do |temp_file|
      # get filename without the temfile's randomly generated unique string
      basename = File.basename(temp_file)
      filename = basename.split('-').first + File.extname(basename)
      files.attach(io: temp_file, filename: filename)

      temp_file.close
      temp_file.unlink
    end
  end

  def remove_files_from_storage
    files.map(&:purge)
  end

  private
  def text_json_is_not_nil
    if text.nil?
      errors.add(:text, "must be set to a json object")
    end
  end
end
