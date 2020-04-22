class AddFrameOrderToTranscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :transcriptions, :frame_order, :string, array: true, default: []
  end
end
