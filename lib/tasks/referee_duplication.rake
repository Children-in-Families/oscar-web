namespace :referee_duplication do
  desc "Remove mtp referee duplication"
  task remove: :environment do
    Organization.switch_to 'mrs'

    referees = Referee.find_by_sql("SELECT id, name, phone count FROM (SELECT *, count(*) OVER (PARTITION BY name ) AS count FROM referees) tableWithCount WHERE tableWithCount.count > 1 AND tableWithCount.name != 'Anonymous'").group_by {|ref| ref.name }
    referees.each do |referee|
      next if referee.first =~ /None/
      referee_id  = referee.last.sort[0].id
      referee_ids = referee.last.sort[1..-1].map(&:id)
      Client.where(referee_id: referee_ids).update_all(referee_id: referee_id)
      Call.where(referee_id: referee_ids).update_all(referee_id: referee_id)
      Referee.where(id: referee_ids).destroy_all
      puts referee.first
    end
  end

end
