module ClientKmo
  class DataClient
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/mko_data.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)
    end

    def update
      clients = Client.includes(:enter_ngos, :exit_ngos, :client_enrollments)
      headers = workbook.each_row_streaming.first.map(&:value)
      client_ids     = workbook.column('A')
      referral_dates = workbook.column('Z')
      accepted_dates = workbook.column('BL')
      ngo_exit_dates = workbook.column('BM')
      enrollment_dates = workbook.column('BF')

      data_transpose = [client_ids, referral_dates, accepted_dates, ngo_exit_dates, enrollment_dates].transpose

      data_transpose.each do |client_id, referral_date, accepted_date, ngo_exit_date, enrollment_date|
        next if client_id == "ID"
        client = clients.find_by(slug: client_id)
        client.initial_referral_date = referral_date
        client.save(validate: false)

        enter_ngos = client.enter_ngos.order(:created_at)

        if accepted_date
          client_enter_ngo = nil
          if enter_ngos.size > 1
            enter_ngos.first.destroy
            client_enter_ngos = Client.find_by(slug: client_id).enter_ngos
            client_enter_ngo = client_enter_ngos.first
            client_enter_ngo.accepted_date = accepted_date.split('|').first.squish
          else
            client_enter_ngo = enter_ngos.first
            client_enter_ngo.accepted_date = accepted_date
          end
          client_enter_ngo.save(validate: false)
        end

        if ngo_exit_date
          exit_ngo = nil
          if client.exit_ngos.size > 1
            exit_ngo = client.exit_ngos.order(exit_date: :desc).first
            exit_ngo.exit_date = ngo_exit_date
          else
            exit_ngo = client.exit_ngos.first
            exit_ngo.exit_date = ngo_exit_date
          end
          exit_ngo.save(validate: false)
        end

        if enrollment_date
          client_enrollment_date = nil
          client_enrollment_dates = client.client_enrollments
          if client_enrollment_dates.size > 1
            leave_program_enrollment = client.client_enrollments.joins(:leave_program)
            if leave_program_enrollment.present?
              if leave_program_enrollment.first.leave_program.exit_date > enrollment_date.to_s.to_date
                client_enrollment_date = client_enrollment_dates.order(:enrollment_date).first
                client_enrollment_date.enrollment_date = enrollment_date
              else
                client_enrollment_date = client_enrollment_dates.order(enrollment_date: :desc).first
                client_enrollment_date.enrollment_date = enrollment_date
              end
            end
            client_enrollment_date.save(validate: false)
          else
            if client_enrollment_dates.present?
              client_enrollment_date = client_enrollment_dates.first
              client_enrollment_date.enrollment_date = enrollment_date
              client_enrollment_date.save(validate: false)
            end
          end
        end
      end

      puts "update kmo client done!"
    end
  end
end
