class CreateDownloads < ActiveRecord::Migration
  
  def change
    create_table :downloads do |t|
      t.string :name, null: false
      t.integer :progress, null: false, default: 0
      t.integer :state, null: false, default: 0
      
      t.timestamps
    end
  end

end
