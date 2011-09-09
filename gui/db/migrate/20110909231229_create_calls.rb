class CreateCalls < ActiveRecord::Migration
  def self.up
    create_table :calls do |t|
      t.string :destination
      t.string :status
      t.string :public_id
      t.string :results

      t.timestamps
    end
  end

  def self.down
    drop_table :calls
  end
end
