class RemoveSubjectIdFromTranscriptions < ActiveRecord::Migration[6.0]
  def change

    remove_column :transcriptions, :subject_id, :int4
  end
end
