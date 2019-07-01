namespace :demo_production do
  desc 'clean demo org on production'
  task clean: :environment do |task, args|
    REFERRAL_SOURCES = ['ក្រសួង សអយ/មន្ទីរ សអយ', 'អង្គការមិនមែនរដ្ឋាភិបាល', 'មន្ទីរពេទ្យ', 'នគរបាល', 'តុលាការ/ប្រព័ន្ធយុត្តិធម៌', 'រកឃើញនៅតាមទីសាធារណៈ', 'ស្ថាប័នរដ្ឋ', 'មណ្ឌលថែទាំបណ្ដោះអាសន្ន', 'ទូរស័ព្ទទាន់ហេតុការណ៍', 'មកដោយខ្លួនឯង', 'គ្រួសារ', 'មិត្តភក្ដិ', 'អាជ្ញាធរដែនដី', 'ផ្សេងៗ', 'សហគមន៍', 'ព្រះវិហារ'].freeze
    Organization.switch_to 'demo'

    clients_without_program_stream = Client.includes(:program_streams).where(program_streams: {id: nil})
    clients_without_program_stream_custom_form = clients_without_program_stream.includes(:custom_fields).where(custom_fields: {id: nil})
    oscar_user_id = User.find_by(first_name: 'OSCaR', last_name: 'Team').id
    
    clients_without_program_stream_custom_form.each do |client|
      client.user_ids = []
      client.family_ids = []
      client.donor_ids = []
      client.donor_id = nil
      client.agency_ids = []
      client.referral_source_id = nil
      client.followed_up_by_id = nil
      client.received_by_id = nil
      client.received_by_id = oscar_user_id
      client.user_ids = [oscar_user_id]
      client.save(validate: false)
    end

    selected_clients = clients_without_program_stream_custom_form.order("RANDOM()").limit(20)
    to_delete_clients = Client.where.not(id: selected_clients.ids)
    ProgramStream.all.each do |p|
      p.really_destroy!
    end
    ClientEnrollment.all.each do |ce|
      ce.leave_program.delete if ce.leave_program.present?
      ce.really_destroy!
    end

    to_delete_clients.each do |client|
      client.client_enrollments.really_destroy! if client.client_enrollments.present?
      client.case_worker_clients.destroy_all
      client.assessments.each do |a|
        begin
          
          a.delete
        rescue => exception
          binding.pry
        end
      end
      client.case_notes.destroy_all
      client.enter_ngos.destroy_all
      client.exit_ngos.destroy_all
      client.government_forms.destroy_all
      client.sponsors.delete_all
      client.tasks.destroy_all
      client.referrals.destroy_all
      Survey.destroy_all
      Attachment.destroy_all
      ProgressNote.all.each do |p|
        begin
          p.delete
        rescue => exception
          binding.pry
        end
      end
      client.program_streams.each do |ps|
        ps.really_destroy!
      end

      begin
        client.delete
      rescue => exception
        binding.pry
      end
    end

    CaseWorkerClient.destroy_all
    Assessment.all.each do |a|
      begin
        
        a.delete
      rescue => exception
        binding.pry
      end
    end

    begin
      to_delete_clients.delete_all
    rescue => exception
      binding.pry
    end
    puts 'finished deleting clients'

    begin
      Family.all.each do |f|
        f.children = []
        f.family_members.delete_all
        f.delete
      end
    rescue => exception
      binding.pry
    end

    begin
      Partner.destroy_all
    rescue => exception
      binding.pry
    end

    begin
      Donor.all.each do |d|
        d.clients = []
        d.delete
      end
    rescue => exception
      binding.pry
    end

    begin
      Department.destroy_all
    rescue => exception
      binding.pry
    end

    begin
      Agency.destroy_all
    rescue => exception
      binding.pry
    end

    begin
      ProgramStream.destroy_all
    rescue => exception
      binding.pry
    end
    CustomField.all.each do |cf|
      cf.custom_field_properties.delete_all
      cf.custom_field_permissions.delete_all
      cf.delete
    end
    Domain.custom_csi_domains.delete_all
    ReferralSource.where.not(name: REFERRAL_SOURCES).delete_all
    User.where.not(id: oscar_user_id).each do |u|
      u.really_destroy!
    end
    OrganizationType.delete_all
    PaperTrail::Version.destroy_all
    puts 'Done'
  end
end
