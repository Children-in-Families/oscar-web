class ClientDecorator < Draper::Decorator
  delegate_all

  def care_code
    model.code.present? ? model.code : ''
  end

  def date_of_birth_format
    model.date_of_birth.strftime('%B %d, %Y') if model.date_of_birth
  end

  def age
    if model.date_of_birth
      year = h.pluralize(model.age_as_years, 'year')
      month = h.pluralize(model.age_extra_months, 'month')
    end
    h.safe_join([year, " #{month}"])
  end

  def current_province
    model.province.name if province
  end

  def birth_province
    Province.find_by_sql("select * from shared.provinces where shared.provinces.id = #{model.birth_province_id} LIMIT 1").first.try(:name) if model.birth_province_id
    # model.birth_province.name if model.birth_province
  end

  def time_in_care
    # h.t('.time_in_care_around', count: model.time_in_care) if model.time_in_care
    return unless model.client_enrollments.any?
    date_time_in_care = { years: 0, months: 0, weeks: 0, days: 0 }
    first_multi_enrolled_program_date = ''
    last_multi_leave_program_date = ''
    ordered_enrollments = model.client_enrollments.order(:enrollment_date)
    ordered_enrollments.each_with_index do |enrollment, index|
      current_enrollment_date = enrollment.enrollment_date
      current_program_exit_date = enrollment.leave_program.try(:exit_date) || Date.today

      next_program_enrollment = ordered_enrollments[index + 1].nil? ? ordered_enrollments[index - 1] : ordered_enrollments[index + 1]
      next_program_enrollment_date = next_program_enrollment.enrollment_date
      next_program_exit_date = next_program_enrollment.leave_program.try(:exit_date) || Date.today
      # binding.pry
      if current_program_exit_date <= next_program_enrollment_date
        if first_multi_enrolled_program_date.present? && last_multi_leave_program_date.present?
          date_time_in_care = h.distance_of_time_in_words_hash(first_multi_enrolled_program_date, last_multi_leave_program_date + date_time_in_care[:years].years + date_time_in_care[:months].months + date_time_in_care[:weeks].weeks + date_time_in_care[:days].days, :except => [:seconds, :minutes, :hours])

          first_multi_enrolled_program_date = ''
          last_multi_leave_program_date = ''
        end
        date_time_in_care = h.distance_of_time_in_words_hash(current_enrollment_date, current_program_exit_date + date_time_in_care[:years].years + date_time_in_care[:months].months + date_time_in_care[:weeks].weeks + date_time_in_care[:days].days, :except => [:seconds, :minutes, :hours])
      else
        first_multi_enrolled_program_date = current_enrollment_date if first_multi_enrolled_program_date == ''
        last_multi_leave_program_date = current_program_exit_date > next_program_exit_date ? current_program_exit_date : next_program_exit_date

        if index == ordered_enrollments.length - 1
          date_time_in_care = h.distance_of_time_in_words_hash(first_multi_enrolled_program_date, last_multi_leave_program_date + date_time_in_care[:years].years + date_time_in_care[:months].months + date_time_in_care[:weeks].weeks + date_time_in_care[:days].days, :except => [:seconds, :minutes, :hours])
        end
      end
    end
    date_time_in_care.to_s
  end

  def referral_date
    model.initial_referral_date.strftime('%B %d, %Y') if model.initial_referral_date
  end

  def referral_source
    model.referral_source.name if model.referral_source
  end

  def received_by
    model.received_by if model.received_by
  end

  def follow_up_by
    model.followed_up_by if model.followed_up_by
  end

  private

  def can_add_ec?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.manager?
  end

  def can_add_fc?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.manager?
  end

  def can_add_kc?
    return true if h.current_user.admin? || h.current_user.case_worker? || h.current_user.manager?
  end
end
