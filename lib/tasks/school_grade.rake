namespace :school_grade do
  desc "fix school grade value, khmer translation"
  task fix: :environment do
    Organization.without_shared.pluck(:short_name).each do |short_name|
      Apartment::Tenant.switch short_name
      puts "Start NGO #{short_name}"
      school_grade_list = {
               "ថ្នាក់មតេយ្យកម្រិត ១" => 'kindergarten_1',
               "ថ្នាក់មតេយ្យកម្រិត ២" => 'kindergarten_2',
               "ថ្នាក់មតេយ្យកម្រិត ៣" => 'kindergarten_3',
               "ថ្នាក់មតេយ្យកម្រិត ៤" => 'kindergarten_4',
               "ថ្នាក់ទី ១" => 'grade_1',
               "ថ្នាក់ទី ២" => 'grade_2',
               "ថ្នាក់ទី ៣" => 'grade_3',
               "ថ្នាក់ទី ៤" => 'grade_4',
               "ថ្នាក់ទី ៥" => 'grade_5',
               "ថ្នាក់ទី ៦" => 'grade_6',
               "ថ្នាក់ទី ៧" => 'grade_7',
               "ថ្នាក់ទី ៨" => 'grade_8',
               "ថ្នាក់ទី ៩" => 'grade_9',
               "ថ្នាក់ទី ១០" => 'grade_10',
               "ថ្នាក់ទី ១១" => 'grade_11',
               "ថ្នាក់ទី ១២" => 'grade_12',
               "ឆ្នាំទី ១" => 'year_1',
               "ឆ្នាំទី ២" => 'year_2',
               "ឆ្នាំទី ៣" => 'year_3',
               "ឆ្នាំទី ៤" => 'year_4',
               "ឆ្នាំទី ៥" => 'year_5',
               "ឆ្នាំទី ៦" => 'year_6',
               "ឆ្នាំទី ៧" => 'year_7',
               "ឆ្នាំទី ៨" => 'year_8',
               "បរិញ្ញាបត្រ" => 'bachelors'
            }
      Client.where.not(school_grade: '').where("school_grade LIKE ?", "ថ្នាក់%").each  do |client|
        grade = client.school_grade
        school_grade_key = school_grade_list[grade]
        school_grade = I18n.t('advanced_search.fields.school_grade_list')[school_grade_key.to_sym]
        client.update_column(:school_grade, school_grade) if school_grade
        puts "#{client.slug}: Grade #{school_grade}"
      end
    end
  end

end
