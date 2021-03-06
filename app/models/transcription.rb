class Transcription < ApplicationRecord
  belongs_to :workflow
  has_many_attached :export_files

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
      export_files.attach(io: temp_file, filename: filename)

      temp_file.close
      temp_file.unlink
    end
  end

  def remove_files_from_storage
    export_files.map(&:purge)
  end

  def lock!(current_user)
    update!(locked_by: current_user.login, lock_timeout: DateTime.now + 3.hours)
  end

  def unlock!
    update!(locked_by: nil, lock_timeout: nil)
  end

  def locked?
    locked_by && lock_timeout && DateTime.now < lock_timeout
  end

  def unlocked?
    !locked?
  end

  def locked_by_different_user?(current_user_login)
    locked? && current_user_login != locked_by
  end

  def is_fresh?(if_unmodified_since)
    # defer to using datetime format used by Rails cache validation
    if_unmodified_since >= updated_at.httpdate
  end

  private

  def text_json_is_not_nil
    errors.add(:text, 'must be set to a json object') if text.nil?
  end
end
