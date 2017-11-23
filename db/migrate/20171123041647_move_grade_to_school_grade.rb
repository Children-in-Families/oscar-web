class MoveGradeToSchoolGrade < ActiveRecord::Migration
  def up
    Client.all.each do |c|
      school_grade = c.grade.nil? ? '' : c.grade
      c.update_columns(school_grade: school_grade)
    end
  end

  def down
  end
end
