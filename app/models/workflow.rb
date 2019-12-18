class Workflow < ApplicationRecord
  belongs_to :project
  has_many :subjects
  has_many :transcriptions

  validates :display_name, presence: true

  def groups
    # aggregate group_id, transcription count, and last update info in one db call
    sql = <<-SQL
    SELECT updated_at, updated_by, t2.group_id, t2.count
    FROM
    transcriptions AS t1
    JOIN
      (SELECT group_id, count(*) AS count, max(updated_at) AS max_date
      FROM transcriptions
      WHERE
        workflow_id = #{id}
      GROUP BY group_id) t2 ON t1.updated_at = t2.max_date;
    SQL

    ActiveRecord::Base.connection.execute(sql)
                      .map do |g|
                        [g['group_id'], 
                        { transcription_count: g['count'], 
                          updated_at: g['updated_at'], 
                          updated_by: g['updated_by'] }]
                      end.to_h
  end

  def total_transcriptions
    transcriptions.count
  end
end
