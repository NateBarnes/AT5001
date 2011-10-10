class AddLineTypeToCall < ActiveRecord::Migration
  def self.up
    add_column :calls, :line_type, :string
  end

  def self.down
    remove_column :calls, :line_type
  end
end
