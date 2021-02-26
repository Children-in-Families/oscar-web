class ConvertVersionsObjectToJson < ActiveRecord::Migration
  def up
    change_column :versions, :object, 'text USING object::text'
    change_column :versions, :object_changes, 'text USING object::text'
  end

  def down
    change_column :versions, :object, 'jsonb USING object::jsonb'
    change_column :versions, :object_changes, 'jsonb USING object::jsonb'
  end
end
