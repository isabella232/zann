class CreateSnacks < ActiveRecord::Migration
  def self.up
    create_table :snacks do |t|
      t.column :name, :string, :limit => 100
      t.column :description, :string, :limit => 1000
      t.column :creator_id, :integer
      t.column :created_at, :datetime
      t.column :image, :string, :limit => 200
      t.column :zanns_count, :integer, :default => 0
    end
  end

  def self.down
    drop_table :snacks
  end
end
