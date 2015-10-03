class CreateCategoriesOperations < ActiveRecord::Migration

  def change  
    create_table :categories_operations, id: false do |t|
      t.belongs_to :operation, index: true
      t.belongs_to :category, index: true
    end
  end

end
