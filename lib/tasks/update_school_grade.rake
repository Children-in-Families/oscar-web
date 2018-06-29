namespace :school_grade do
  desc 'update all clients school grade'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      kindergarten_1 = ['មត្តេយ្យថ្នាក់១', 'Kindergarten 1']
      kindergarten_2 = ['មត្តេយ្យថ្នាក់២', 'Kindergarten 2']
      kindergarten_3 = ['មត្តេយ្យថ្នាក់៣', 'Kindergarten 3']
      kindergarten_4 = ['មត្យេយ', 'មត្តេយ្យ', '0 (មតេយ្យ)', 'មត្តេយ្យជាន់ខ្ពស់', 'kindergarten', 'មតេ្តយ្យ', 'KG', 'មតេយ្យកម្រិតខ្ពស់', 'មតេ្តយ្យកម្រិតខ្ពស់', 'មតេ្តយ្យកម្រិតទាប', 'មតេយ្យកម្រិតទាប', 'មត្តេយ្យកម្រិតខ្ពស់', 'Kindergarten 4']
      grade_1 = ['1', 'ទី1', '01', 'Grade 1', 'ថា្នក់ទី១', 'ថ្នាក់ទី១', '1 (ខ២)', '1(ខ1)', '1 (ខ1)', '1 (ខ១)', '1 (ក១)\n']
      grade_2 = ['2', '២', 'Grade 2', 'ទី2', "ថ្នាក់ទី២ (គ)", '2 \"ក\"', 'ថ្នាក់ទី២', 'Level2', 'grade 2', 'Grade  2', '២ឃ២', '2(ក២)', '2 (ក២)', '2(ខ១)']
      grade_3 = ['3', '៣', 'Grade 3', 'ថ្នាក់ទី៣', 'Grade 3 ', '៣ង២', '3 (គ១)', '3 (គ2)', '3(ខ១)']
      grade_4 = ['4', '៤', 'Grade 4', 'Grade 4 ', 'grade 4', '4(ខ1)', '4 (គ១)', '4 (ខ១)']
      grade_5 = ['5', '៥', 'ថ្នាក់ទី៥', 'Grade 5', 'grade 5', '5 (ក២)', '5 (ខ២)']
      grade_6 = ['6', '៦', '06', 'ថ្នាក់ទី៦', 'Grade 6', 'grade 6', 'Grade 6 ', 'Standard 6', '6 (ខ១)']
      grade_7 = ['7', '៧', '០៧', 'Grade 7', '7D1', '7 (C1)']
      grade_8 = ['8', '08', '៨', 'Grade 8', '8 (C2)', '8(B2)']
      grade_9 = ['9']
      grade_10 = ['10', '១០', '10 (Einstein Boardering School)', 'ទី១០']
      grade_11 = ['11', '១១', '11 (no schooling now)']
      grade_12 = ['12', '១២', 'ទី១២']
      year_1 = ["ឆ្នាំទី១ ផ្នែក  Nurse", 'Year 1', '1st year', 'U1', 'University 1', 'year 1']
      year_2 = ['2nd year', 'Second year in Bible school (B.Th)', 'U2', 'Year 2']
      year_3 = ['University 3 year', 'U3', 'University 3', 'Year 3']
      year_4 = ['University last year', '4th year', 'Gth. (Bible school), final year', 'Year 4']

      Client.all.each do |client|
        if client.school_grade.in? kindergarten_1
          client.school_grade = 'Kindergarten 1'
        elsif client.school_grade.in? kindergarten_2
          client.school_grade = 'Kindergarten 2'
        elsif client.school_grade.in? kindergarten_3
          client.school_grade = 'Kindergarten 3'
        elsif client.school_grade.in? kindergarten_4
          client.school_grade = 'Kindergarten 4'
        elsif client.school_grade.in? grade_1
          client.school_grade = '1'
        elsif client.school_grade.in? grade_2
          client.school_grade = '2'
        elsif client.school_grade.in? grade_3
          client.school_grade = '3'
        elsif client.school_grade.in? grade_4
          client.school_grade = '4'
        elsif client.school_grade.in? grade_5
          client.school_grade = '5'
        elsif client.school_grade.in? grade_6
          client.school_grade = '6'
        elsif client.school_grade.in? grade_7
          client.school_grade = '7'
        elsif client.school_grade.in? grade_8
          client.school_grade = '8'
        elsif client.school_grade.in? grade_9
          client.school_grade = '9'
        elsif client.school_grade.in? grade_10
          client.school_grade = '10'
        elsif client.school_grade.in? grade_11
          client.school_grade = '11'
        elsif client.school_grade.in? grade_12
          client.school_grade = '12'
        elsif client.school_grade.in? year_1
          client.school_grade = 'Year 1'
        elsif client.school_grade.in? year_2
          client.school_grade = 'Year 2'
        elsif client.school_grade.in? year_3
          client.school_grade = 'Year 3'
        elsif client.school_grade.in? year_4
          client.school_grade = 'Year 4'
        else
          client.school_grade = ''
        end
        client.save(validate: false)
      end
    end
  end
end
