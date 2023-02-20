module ClientByGenderCountHelper
  def adule_client_gender_count(clients, type = :male, referrals = nil)
    if referrals
      age_sql_string = <<-SQL.squish
        (CASE WHEN (EXTRACT(year FROM age(current_date, referrals.client_date_of_birth)) :: int) >= 0 THEN (EXTRACT(year FROM age(current_date, referrals.client_date_of_birth)) :: int) ELSE 0 END)
      SQL
      referrals.where("referrals.client_gender = ? AND #{age_sql_string} >= ?", type.to_s, 18).count
    else
      age_sql_string = <<-SQL.squish
        (CASE WHEN (EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= 0 THEN (EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) ELSE 0 END)
      SQL
      clients.public_send(type).where("#{age_sql_string} >= ?", 18).count
    end
  end

  def under_18_client_gender_count(clients, type = :male, referrals = nil)
    if referrals
      age_sql_string = <<-SQL.squish
        (CASE WHEN (EXTRACT(year FROM age(current_date, referrals.client_date_of_birth)) :: int) >= 0 THEN (EXTRACT(year FROM age(current_date, referrals.client_date_of_birth)) :: int) ELSE 0 END)
      SQL
      referrals.where("referrals.client_gender = ? AND #{age_sql_string} < ?", type.to_s, 18).count
    else
      age_sql_string = <<-SQL.squish
        (CASE WHEN (EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) >= 0 THEN (EXTRACT(year FROM age(current_date, clients.date_of_birth)) :: int) ELSE 0 END)
      SQL
      clients.public_send(type).where("#{age_sql_string} < ?", 18).count
    end
  end

  def other_client_gender_count(clients, referrals = nil)
    if referrals
      referrals.where("client_gender IS NOT NULL AND (client_gender NOT IN ('male', 'female') OR client_date_of_birth IS NULL)").count
    else
      clients.where("gender IS NULL OR (gender IS NOT NULL AND gender NOT IN ('male', 'female')) OR (gender NOT IN ('male', 'female') AND date_of_birth IS NULL)").count
    end
  end
end
