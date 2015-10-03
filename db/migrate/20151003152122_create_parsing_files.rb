class CreateParsingFiles < ActiveRecord::Migration

  def change
    create_table :parsing_files do |t|
      t.integer :parsed_rows, null: false, default: 0
      t.integer :valid_rows, null: false, default: 0
      t.integer :invalid_rows, null: false, default: 0
      t.integer :state, null: false, default: 0

      t.timestamps
    end
    add_attachment :parsing_files, :file
  end

end
