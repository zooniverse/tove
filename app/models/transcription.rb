class Transcription < ApplicationRecord
  belongs_to :workflow
  belongs_to :subject

  validates :text, presence: true
  validates :subject_id, presence: true
  validates :status, presence: true
  validates :group_id, presence: true

  enum status: {
    unseen: 0,
    ready: 1,
    approved: 2
  }
end
