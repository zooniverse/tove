class Transcription < ApplicationRecord
  belongs_to :workflow

  validates :status, presence: true
  validates :group_id, presence: true
  validate :text_json_is_not_nil

  enum status: {
    approved: 0,
    in_progress: 1,
    ready: 2, # ready as in "ready for approval"
    unseen: 3

  }

  private
  def text_json_is_not_nil
    if text.nil?
      errors.add(:text, "must be set to a json object")
    end
  end
end
