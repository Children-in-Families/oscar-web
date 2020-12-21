class RemoveDefaultValueIdPoorAndGradeInClient < ActiveRecord::Migration[5.2]
  def up
    change_column_default :clients, :id_poor, nil
    change_column_default :clients, :grade, nil
  end

  def down
    change_column_default :clients, :id_poor, 0
    change_column_default :clients, :grade, 0
  end
end
