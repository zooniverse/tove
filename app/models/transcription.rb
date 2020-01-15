class Transcription < ApplicationRecord
  belongs_to :workflow

  validates :status, presence: true
  validates :group_id, presence: true
  validate :text_json_is_not_nil

  enum status: {
    unseen: 0,
    ready: 1, # ready as in "ready for approval"
    approved: 2,
    in_progress: 3

  }

  private
  def text_json_is_not_nil
    if text.nil?
      errors.add(:text, "must be set to a json object")
    end
  end
end
