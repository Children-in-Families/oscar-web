namespace :cfi_line_manager_users do
  desc 'Update line manager users of CFI'
  task update: :environment do
    Organization.switch_to 'cfi'

    User.where(manager_id: nil).each do |user|
      user.update_columns(manager_ids: [])
    end

    User.where(manager_id: 16).each do |user|
      user.update_columns(manager_ids: [16])
    end

    User.where(manager_id: 5).each do |user|
      user.update_columns(manager_ids: [5])
    end

    User.where(manager_id: 15).each do |user|
      user.update_columns(manager_ids: [15, 6])
    end

    User.where(manager_id: 6).each do |user|
      user.update_columns(manager_ids: [6])
    end

    User.where(manager_id: 9).each do |user|
      user.update_columns(manager_ids: [9, 6])
    end

    # user 19 was deleted by the NGO
    User.where(manager_id: 19).each do |user|
      user.update_columns(manager_id: nil, manager_ids: [])
    end
  end
end
