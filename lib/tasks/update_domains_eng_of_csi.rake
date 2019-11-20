namespace :update_domains_eng_of_csi do
  desc 'update all domain eng of csi'
  task update: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      domains =
      [
        {
          name: "1A",
          group: 1,
          description: "<p><u></u><u><strong>Domains : 1A (Food Security)</strong></u></p>\r\n<p><strong>&nbsp;</strong></p>\r\n<p><strong>Goal: The child has enough food to eat at all times of the year.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>What do the family and child eat?</p>\r\n</li>\r\n<li>\r\n<p>How does the household get food?</p>\r\n</li>\r\n<li>\r\n<p>Tell me about times when there is not enough food?</p>\r\n</li>\r\n<li>\r\n<p>Does the child complain about being hungry?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Observe the house/farm. Are they crops and/or animals?</p>\r\n</li>\r\n<li>\r\n<p>Does the kitchen look as though it was used to prepare food recently?</p>\r\n</li>\r\n<li>\r\n<p>How much rice can you see? </p>\r\n</li>\r\n<li>\r\n<p>Can you see signs of recent food preparation/leftovers? </p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child frequently has less food to eat than needed, complains of hunger. ",
        },
        {
          name: "1B",
          group: 1,
          description: "<p><u><strong>Domains : 1B (Nutrition and Growth)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is growing well compared to others of his/her age in the community.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>How is the child growing?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she seems to be growing like other children the same age?</p>\r\n</li>\r\n<li>\r\n<p>Are you worried about this child's growth? Weight? Height?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Compare how well the child seems to have grown with other local children the same age.</p>\r\n</li>\r\n<li>\r\n<p>Look carefully at babies and children under 5 if you can see thin limbs, large head, swollen belly.</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child has low weight, looks shorter, and/or is less energetic compared to others of the same age in the community. ",
        },
        {
          name: "2A",
          group: 2,
          description: "<p><u><strong>Domains : 2A (Shelter)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child has stable shelter that is safe, adequate and dry.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Where does the child live?</p>\r\n</li>\r\n<li>\r\n<p>Are there any difficulties with the house?</p>\r\n</li>\r\n<li>\r\n<p>Where does the child sleep?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Is the house adequate for the size of the family living in it?</p>\r\n</li>\r\n<li>\r\n<p>Is the house in need of repairs?</p>\r\n</li>\r\n<li>\r\n<p>Is the child's sleeping(bedroom) area in the same level of repair as the rest of the house?</p>\r\n</li>\r\n<li>\r\n<p>Is the house safe for the child's needs, at their age and stage of development?</p>\r\n</li>\r\n<li>\r\n<p>Is there a safe and hygienic area nearby  to shower and use a toilet?</p>\r\n</li>\r\n<li>\r\n<p>Is the access to the house (stairs, entrance) safe? </p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child lives in a place that needs major repairs, is overcrowded, inadequate, and/or does not protect him/her from the weather. ",
        },
        {
          name: "2B",
          group: 2,
          description: "<p><u><strong>Domains : 2B (Care)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child has at least one adult (aged 18 or over) who provides consistent care, attention and support.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Who is the most important adult in the child's life?</p>\r\n</li>\r\n<li>\r\n<p>Who takes care of this child?</p>\r\n</li>\r\n<li>\r\n<p>Is this person going to look after the child until they grow up? </p>\r\n</li>\r\n<li>\r\n<p>When something exciting or fun happens, who does the child tell?</p>\r\n</li>\r\n<li>\r\n<p>Who does the child go to if he/she feel sad? Or worried?</p>\r\n</li>\r\n<li>\r\n<p>Who does the child go to if he/she is hurt?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>How do the child and adult interact?</p>\r\n</li>\r\n<li>\r\n<p>Do they seem to know one anther well?</p>\r\n</li>\r\n<li>\r\n<p>Is the relationship between the adult and the child appropriately affectionate?</p>\r\n</li>\r\n<li>\r\n<p>Has the child’s main carer changed in the time you have known the family?</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child has no consistent adult in his/her life that provides love, attention and support. ",
        },
        {
          name: "3A",
          group: 3,
          description: "<p><u><strong>Domains : 3A (Protection from Abuse and Exploitation)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is safe from any abuse, neglect or exploitation.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does anyone hurt this child?</p>\r\n</li>\r\n<li>\r\n<p>Do you think the child feels safe?</p>\r\n</li>\r\n<li>\r\n<p>Does the child work for anyone outside the household?</p>\r\n</li>\r\n<li>\r\n<p>Does the child work at night? </p>\r\n</li>\r\n<li>\r\n<p>Does the child work in the streets or the market? What happens with the money they earn? </p>\r\n</li>\r\n<li>\r\n<p>Does anyone else who knows the child think he/she is being hurt or sexually abused by someone else?</p>\r\n</li>\r\n<li>\r\n<p>(Ask child): Are you ever afraid to come home because something bad might happen? </p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the child have any marks or bruises that suggest abuse?</p>\r\n</li>\r\n<li>\r\n<p>Is the child withdrawn or scared? Does the child seem too busy for a child of his/her age?</p>\r\n</li>\r\n<li>\r\n<p>Does the child seem easily startled?</p>\r\n</li>\r\n<li>\r\n<p>Does the child demonstrate inappropriately sexualised behaviour?</p>\r\n</li>\r\n<li>\r\n<p>Look for signs of neglect such as being dirty, wounded feet from walking without shoes on, appropriate clothing.</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child is neglected, given inappropriate work for his/her age, or is clearly not treated well in the household. ",
        },
        {
          name: "3B",
          group: 3,
          description: "<p><u><strong>Domains : 3B (Legal Protection)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child has access to legal protection services as needed.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does this child have a birth certificate or registration?</p>\r\n</li>\r\n<li>\r\n<p>Is the child listed in the family book?</p>\r\n</li>\r\n<li>\r\n<p>Does the family have a legal will?</p>\r\n</li>\r\n<li>\r\n<p>Has the child ever been refused any services because of legal status?</p>\r\n</li>\r\n<li>\r\n<p>Does the family have ID poor?</p>\r\n</li>\r\n<li>\r\n<p>Do you know any legal problems for the child (such as land grabbing)?</p>\r\n</li>\r\n<li>\r\n<p>Does this child have an adult to stand up for his/her legal rights and protection?</p>\r\n</li>\r\n<li>\r\n<p>Are there any problems obtaining identification, birth or poverty documents from the local authorities?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the caregiver seem to hesitate or worry when asked about the child's legal status?</p>\r\n</li>\r\n<li>\r\n<p>Can the caregiver show you the child’s legal documents?</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child has no access to any legal protection and may be at risk of exploitation. ",
        },
        {
          name: "4A",
          group: 4,
          description: "<p><u><strong>Domains : 4A (Wellness)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is physically healthy.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Tell me about this child's health.</p>\r\n</li>\r\n<li>\r\n<p>Tell me about the last sickness this child had.</p>\r\n</li>\r\n<li>\r\n<p>Has the child missed school or work recently because of illness?</p>\r\n</li>\r\n<li>\r\n<p>Has the baby/child had a fever recently?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong> Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the child seem to be active and generally healthy?</p>\r\n</li>\r\n<li>\r\n<p>Are there wounds, signs of illness or fever?</p>\r\n</li>\r\n</ul>",
          score_2_definition: "In the past month, the child was often (more than three days) ill for school, work or play. ",
        },
        {
          name: "4B",
          group: 4,
          description: "<p><u><strong>Domains : 4B (Health Care Services)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child can access health care services, including medical treatment when ill, and preventive care.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>What happens when this child gets sick?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she see a nurse, doctor or any other health professional?</p>\r\n</li>\r\n<li>\r\n<p>When he/she needs medicine, how does he/she get it?</p>\r\n</li>\r\n<li>\r\n<p>Has the child been immunised and are these immunisations up to date?</p>\r\n</li>\r\n<li>\r\n<p>Has anyone talked to the child about risks for the HIV/AIDS, dengue fever, malaria, tuberculosis, and how to protect against these risks?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>If possible, observe the child's immunisation card.</p>\r\n</li>\r\n<li>\r\n<p>Does the child has a mosquito net for their bed?</p>\r\n</li>\r\n<li>\r\n<p>What health services are available in the local area?</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child only sometimes or inconsistently receive needed health care services (treatment or preventive). ",
        },
        {
          name: "5A",
          group: 5,
          description: "<p><u><strong>Domains : 5A (Emotional Health)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is happy and content with a generally positive and hopeful outlook.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Is the child usually happy or usually sad?</p>\r\n</li>\r\n<li>\r\n<p>How can you tell if the child is happy/unhappy?</p>\r\n</li>\r\n<li>\r\n<p>Do you worry about this child's sadness or grief?</p>\r\n</li>\r\n<li>\r\n<p>Have you ever thought the child did not want to live any more?</p>\r\n</li>\r\n<li>\r\n<p>Do you worry he/she might hurt her/himself?</p>\r\n</li>\r\n<li>\r\n<p>(Ask the child) Do you think you have a good life?</p>\r\n</li>\r\n<li>\r\n<p>(Ask the child) Do you feel that you will have a good future?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the child seem happy in the home? In school/training?</p>\r\n</li>\r\n<li>\r\n<p>Is the child willing to talk to the visitor?</p>\r\n</li>\r\n<li>\r\n<p>Does the child's face express emotions?&nbsp;</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child is often withdrawn, irritable, anxious, unhappy or sad. An infant may cry frequently or often be inactive. ",
        },
        {
          name: "5B",
          group: 5,
          description: "<p><u><strong>Domain: 5B Social Behavior</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child cooperates and enjoys participating in activities with adults and other children.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>What is the child's behaviour like toward adults? Is he/she obedient?</p>\r\n</li>\r\n<li>\r\n<p>Does the child usually follow rules at home and in school?</p>\r\n</li>\r\n<li>\r\n<p>Does the child play with other children or have close friends? Does he/she enjoy being with other children?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she fight with other children?</p>\r\n</li>\r\n<li>\r\n<p>Do you worry about the child having problems with others at school?</p>\r\n</li>\r\n<li>\r\n<p>How does the child react with the CCW?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Observations:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the child behave in ways that seem positive and appropriate with others in the house?</p>\r\n</li>\r\n<li>\r\n<p>Does the child seem to behave in a way that is especially violent, disruptive or dangerous?</p>\r\n</li>\r\n<li>\r\n<p>Does the child seem very disengaged from others and stay alone?</p>\r\n</li>\r\n<li>\r\n<p>Is the child engaging in any dangerous behaviors such as drug use, unsafe/early sexual activity, alcohol, staying out late?</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child disobedient to adults, and oftenly does not interact with peers, guardian, or other at home or school.",
        },
        {
          name: "6A",
          group: 6,
          description: "<p><span style=\"text-decoration: underline;\"><strong>Domains : 6A (Performance)</strong></span></p>\r\n<p>&nbsp;</p>\r\n<p>Goal: The child is progress well in acquiring knowledge and skills at home, school, job, training, or an age-appropriate productive activity.</p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Is this child developing as you would expect?</p>\r\n</li>\r\n<li>\r\n<p>Is this child learning new things, such as walking, speaking, and skills, as you would expect of others his/her age?</p>\r\n</li>\r\n<li>\r\n<p>Do you worry about this child's performance or learning?</p>\r\n</li>\r\n<li>\r\n<p>Is the child quick to understand and learn?</p>\r\n</li>\r\n<li>\r\n<p>Do teachers report that child is doing well at school?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she do a good job with chores at home, such as work in the garden?</p>\r\n</li>\r\n<li>\r\n<p>Is the child advancing to the next grade as expected?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>If an adolescent, ask the child about skills training and learning skill that are useful for him/her.</p>\r\n</li>\r\n<li>\r\n<p>If in school, observe the response if ask about class performance and ranking</p>\r\n</li>\r\n<li>\r\n<p>If the child is 5 years old or younger, observe the child development or progress (in language, in movement, in learning) and compare this to what you expect for children of the same age.</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child is gaining skill poorly and/or is falling behind. An infant or preschool child is gaining skills more slowly than his/her peers.",
        },
        {
          name: "6B",
          group: 6,
          description: "<p><u><strong>Domain: 6B Education and Work</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is enrolled and attends school, or skill training, or is engaged in age-appropriate play, learning, activities or job.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Is the child in, or has he/she completed, primary school?</p>\r\n</li>\r\n<li>\r\n<p>Tell me about the child's school or training</p>\r\n</li>\r\n<li>\r\n<p>Who pays school fee and buys uniforms and school materials?</p>\r\n</li>\r\n<li>\r\n<p>Does the child attend the school regularly?</p>\r\n</li>\r\n<li>\r\n<p>How often must the child miss school for any reason?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she go to work regularly?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Observe any school aged children who are outside of school during school time and school days.</p>\r\n</li>\r\n<li>\r\n<p>If possible, observe the child's school uniform, or supplies, or their usage</p>\r\n</li>\r\n<li>\r\n<p>If an infant or preschooler, observe if he/she is involved in any play or learning with any family member?</p>\r\n</li>\r\n</ul>",
          score_2_definition: "The child is enrolled in school or has a job, but he/she rarely attends. An infant or preschooler is rarely played with. ",
        }
      ]
      domains.each do |domain|
        dom = Domain.find_by(name: domain[:name])
        if dom.present?
          dom.description = domain[:description]
          dom.score_2_definition = domain[:score_2_definition]
          dom.save(validate: false)
          dom.update_columns('description' => domain[:description])
          dom.update_columns('score_2_definition' => domain[:score_2_definition])
        end
      end
    end
  end
end
