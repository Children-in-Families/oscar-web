namespace :domains_standard_english do
  desc 'Add domains score definition in English only based on CIF'
  task update: :environment do
    standard_domains_english_orgs = ['gca', 'kmo', 'cccu', 'spo']

    standard_domains_english_orgs.each do |org|
      unprocessable_domains = []

      next if Organization.find_by(short_name: org).nil?
      Organization.switch_to org

      new_domains = fetch_domains_score_english
      new_domains.each do |new_domain|
        old_domain = Domain.find_by(name: new_domain[:name], identity: new_domain[:identity])
        if org == 'spo' && old_domain.name == '1B'
          new_desctipion = old_domain.description.split('<p>Score Interpretation').first.concat('</p>')
        else
          new_desctipion = old_domain.description.split('<hr />').first.concat('</p>')
        end

        begin
          old_domain.update(
            description: new_desctipion,
            score_1_definition: new_domain[:score_1_definition],
            score_2_definition: new_domain[:score_2_definition],
            score_3_definition: new_domain[:score_3_definition],
            score_4_definition: new_domain[:score_4_definition])
        rescue
          unprocessable_domains << { org: { name: org, domain_id: old_domain.id }  }
        end
      end
      system "echo #{unprocessable_domains} >> log/#{org}_unprocessable_domains.txt" if unprocessable_domains.present?
    end
  end
end

private

def fetch_domains_score_english
  [
    {
      "name":"1A",
      "identity":"Food Security",
      "score_1_definition":"1: The child rarely has food to eat and goes to bed hungry most nights.",
      "score_2_definition":"2: The child frequently has less food to eat than needed, complains of hunger.",
      "score_3_definition":"3: The child has enough to eat for some of time, depending on season or food supply.",
      "score_4_definition":"4: The child is well fed, eats regularly."},
    {
      "name":"1B",
      "identity":"Nutrition and Growth",
      "score_1_definition":"1:The child has very low weight or is too short for his or her age.",
      "score_2_definition":"2:The child has low weight, looks shorter, and/or is less energetic compared to others of the same age in the community.",
      "score_3_definition":"3:The child seems to be growing well but is less active compared to others of the same age in the community.",
      "score_4_definition":"4:The child is growing well with good height, weight and energy level for his/her age."},
    {
      "name":"2A",
      "identity":"Shelter",
      "score_1_definition":"1:The child has no stable, adequate or safe place to live.",
      "score_2_definition":"2:The child lives in a place that needs major repairs, is overcrowded, inadequate, and/or does not protect him/her from the weather.",
      "score_3_definition":"3:The child lives in a place that needs some repairs, but is fairly adequate, dry and safe.",
      "score_4_definition":"4:The child lives in a place that is adequate, dry and safe."},
    {
      "name":"2B",
      "identity":"Care",
      "score_1_definition":"1: The child is completely without the care of an adult and must fend for him or herself, or lives in a child-headed household.",
      "score_2_definition":"2: The child has no consistent adult in his/her life that provides love, attention and support.",
      "score_3_definition":"3: The child has an adult who provides care but who is limited by illness or age, or seems indifferent to the child.",
      "score_4_definition":"4: The child has a primary caregiver who is involved in his/her life and who protects nurtures him/her."},
    {
      "name":"3A",
      "identity":"Protection from Abuse and Exploitation",
      "score_1_definition":"1: The child is abused, sexually or physically,and/or is being subjected to the child labour or other exploitation.",
      "score_2_definition":"2: The child is neglected, given inappropriate work for his/her age, or is clearly not treated well in the household.",
      "score_3_definition":"3: There is some suspicion that the child may be neglected, over-worked, treated poorly, or otherwise mistreated.",
      "score_4_definition":"4: The child does not seem to be abused or neglected, does not do inappropriate work, and does not seem exploited in other ways."},
    {
      "name":"3B",
      "identity":"Legal Protection",
      "score_1_definition":"1: The child has no access to any legal protection services and is being legally exploited.",
      "score_2_definition":"2: The child has no access to any legal protection and may be at risk of exploitation.",
      "score_3_definition":"3: The child has no access to legal protection services, but no protection is needed at this time.",
      "score_4_definition":"4: The child has access to legal protection as needed."},
    {
      "name":"4A",
      "identity":"Wellness",
      "score_1_definition":"1: In the past month, the child has been ill most of the time (chronically ill).",
      "score_2_definition":"2: In the past month, the child was often (more than three days) ill for school, work or play.",
      "score_3_definition":"3: In the past month, the child was ill and less active for a few days (1-3) but he/she was able to take part in some normal activities.",
      "score_4_definition":"4: In the past month, the child has been healthy and active, with no fever, diarrhea, or other illness."},
    {
      "name":"4B",
      "identity":"Health Care Services",
      "score_1_definition":"1: The child rarely or never received the necessary health care services.",
      "score_2_definition":"2: The child only sometimes or inconsistently receive needed health care services (treatment or preventive).",
      "score_3_definition":"3: The child receive medical treatment when ill, but some health care services (eg. immunisations) are not received.",
      "score_4_definition":"4: The child has received all or almost necessary health care treatment and preventive services."},
    {
      "name":"5A",
      "identity":"Emotional Health",
      "score_1_definition":"1. The child seems hopeless, sad, withdraw, wishes he/she could die, or want to be left alone. An infant refuses to eat, sleeps poorly, cries a lot.",
      "score_2_definition":"2. The child is often withdrawn, irritable, anxious, unhappy or sad. An infant may cry frequently or often be inactive.",
      "score_3_definition":"3. The child is mostly happy, but occasionally he/she is anxious, withdraw. An infant may be crying, or not sleeping well some of the time.",
      "score_4_definition":"4. The child seems happy, hopeful, and content."},
    {
      "name":"5B",
      "identity":"Social Behaviour",
      "score_1_definition":"1. The child has behavioral problems, including stealing, early sexual activity, and/ or other disruptive behavior.",
      "score_2_definition":"2. The child disobedient to adults, and often does not interact with peers, guardian, or other at home or school.",
      "score_3_definition":"3. The child has minor problems getting along with others and argues or get into fight sometimes.",
      "score_4_definition":"4. The child likes to play with peers and anticipates with group or family activities."},
    {
      "name":"6A",
      "identity":"Performance",
      "score_1_definition":"1. The child has serious problems with performance and learning in life or developmental skills.",
      "score_2_definition":"2 The child is gaining skill poorly and/or is falling behind. An infant or preschool child is gaining skills more slowly than his/her peers",
      "score_3_definition":"3. The child is learning well and developing life skills fairly well, but caregivers, teachers and other leaders have some concern about progress.",
      "score_4_definition":"4. The child is learning well, developing life skills, and progressing as expected by caregivers, teachers or other leaders."},
    {
      "name":"6B",
      "identity":"Work and Education",
      "score_1_definition":"1. The child is not enrolled in school, not attending training, or not involve in an age-appropriate productive activity or job. An infant or preschooler is not played with.",
      "score_2_definition":"2. The child is enrolled in school or has a job, but he/she rarely attends. An infant or preschooler is rarely played with.",
      "score_3_definition":"3. The child is enrolled in school or training, but attends irrigularly or shows up inconsistantly for it, or for a productive activity or job. Younger children are played with sometimes, but not daily.",
      "score_4_definition":"4. The child is enrolled in and attending school/ training regularly. Infants/preschoolers play with their caregiver. An older child has an appropriate job."}
    ]
end
