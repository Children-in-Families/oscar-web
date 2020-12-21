class AddGradeToClient < ActiveRecord::Migration[5.2]

  def change

    add_column :clients, :grade, :integer, default: 0

    unprocessable_clients = []

    puts '==========Processing=========='

    Client.find_each do |client|
      grade = client.school_grade.to_i
      begin
        client.update_attributes!(grade: grade)
      rescue
        unprocessable_clients << client.id
      end
    end

    puts '==========Done=========='

    system "echo #{unprocessable_clients} >> error.txt" if unprocessable_clients.present?
  end

end
