namespace :domains_standard_translation_seed do
  desc 'Seed standard CSI domains in English and Khmer based on CIF'
  task update: :environment do

    Organization.all.each do |org|
      Organization.switch_to org.short_name

      domains = fetch_domains
      domains.each do |domain|
        new_domain = Domain.csi_domains.find_by(
          name: domain['name'],
          identity: domain['identity']
        )

        next if new_domain.nil?
        new_domain.update(
          description: domain['description'],
          local_description: domain['local_description'],
          score_1_definition: domain['score_1_definition'],
          score_2_definition: domain['score_2_definition'],
          score_3_definition: domain['score_3_definition'],
          score_4_definition: domain['score_4_definition'],
          score_1_local_definition: domain['score_1_local_definition'],
          score_2_local_definition: domain['score_2_local_definition'],
          score_3_local_definition: domain['score_3_local_definition'],
          score_4_local_definition: domain['score_4_local_definition']
        )
      end
    end
  end
end

private

def fetch_domains
  domains_score_definition =
  [
    {
    "name"=>"1A",
    "identity"=>"Food Security",
    "description"=>"<p><u></u><u><strong>Domains : 1A (Food Security)</strong></u></p>\r\n<p><strong>&nbsp;</strong></p>\r\n<p><strong>Goal: The child has enough food to eat at all times of the year.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>What do the family and child eat?</p>\r\n</li>\r\n<li>\r\n<p>How does the household get food?</p>\r\n</li>\r\n<li>\r\n<p>Tell me about times when there is not enough food?</p>\r\n</li>\r\n<li>\r\n<p>Does the child complain about being hungry?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Observe the house/farm. Are they crops and/or animals?</p>\r\n</li>\r\n<li>\r\n<p>Does the kitchen look as though it was used to prepare food recently?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>12,
    "score_1_definition"=>"The child rarely has food to eat and goes to bed hungry most nights.",
    "score_2_definition"=>"The child frequently has less food to eat than needed, complains of hunger.",
    "score_3_definition"=>"The child has enough to eat for some of time, depending on season or food supply.",
    "score_4_definition"=>"The child is well fed, eats regularly.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា ៖ ១ក (សុវត្ថិភាពស្បៀងអាហារ)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារមានអាហារបរិភោគគ្រប់គ្រាន់គ្រប់ពេលសំរាប់ឆ្នាំនេះ។<strong><br /></strong></p>\r\n<p><strong>សំនួរគំរូ៖</strong></p>\r\n<ul>\r\n<li><strong>តើគ្រួសារ/កុមារមានអ្វីបរិភោគខ្លះ?</strong></li>\r\n<li><strong>តើគ្រួសារទទួលបានអាហារដោយរបៀបណា?</strong></li>\r\n<li><strong>សូមប្រាប់ខ្ញុំពីពេលវេលាកាលដែលមិនមានអាហារបរិភោគគ្រប់គ្រាន់។</strong></li>\r\n<li><strong>តើកុមារនេះត្អូញត្អែពីការអត់ឃ្លានរឺទេ?</strong></li>\r\n</ul>\r\n<p><strong>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</strong></p>\r\n<ul>\r\n<li><strong>សូមអង្កេតមើលលើផ្ទះ/សត្វចិញ្ចឹមក្នុងបរិវេនផ្ទះ។ តើពួកគេមានដំណាំ និង /ឬ មានសត្វចិញ្ចឹមដែររឺទេ?</strong></li>\r\n<li><strong>តើផ្ទះបាយមើលទៅហាក់ដូចជាទើបនឹងប្រើដើម្បីចំអិនអាហារថ្មីៗ រឺទេ?</strong></li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារមិនសូវ មានឣាហារបរិភោគ ហើយចូលគេងទាំងឃ្លាន ស្ទើររាល់យប់។",
    "score_2_local_definition"=>"កុមារជាញឹកញាប់មានអាហារបរិភោគតិចតួចជាងតម្រូវការ និងត្អូញត្អែរពី ការ ឃ្លាន។",
    "score_3_local_definition"=>"នៅពេលខ្លះ កុមារ បរិភោគ គ្រប់គ្រាន់ ឣាស្រ័យទៅលើរដូវកាល ឬការផ្គត់ផ្គង់អាហារ។",
    "score_4_local_definition"=>"កុមារមានអាហារផ្គត់ផ្គង់គ្រប់ គ្រាន់, បរិភោគបានជាទៀងទាត់។"
    },
    {
    "name"=>"1B",
    "identity"=>"Nutrition and Growth",
    "description"=>"<p><u><strong>Domains : 1B (Nutrition and Growth)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is growing well compared to others of his/her age in the community.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>How is the child growing?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she seems to be growing like other children the same age?</p>\r\n</li>\r\n<li>\r\n<p>Are you worried about this child's growth? Weight? Height?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Compare how well the child seems to have grown with other local children the same age.</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>12,
    "score_1_definition"=>"The child has very low weight or is too short for his or her age.",
    "score_2_definition"=>"The child has low weight, looks shorter, and/or is less energetic compared to others of the same age in the community.",
    "score_3_definition"=>"The child seems to be growing well but is less active compared to others of the same age in the community.",
    "score_4_definition"=>"The child is growing well with good height, weight and energy level for his/her age.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ១ខ (ឣាហាររូបត្ថម្ភ និងការលូតលាស់)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារ កំពុងលូតលាស់ បាន ល្អ បើប្រៀបធៀបទៅនឹង កុមារ ផ្សេងៗទៀតដែលមានអាយុ ដូច គាត់/នាង នៅក្នុង សហគ មន៍ ។</p>\r\n<p>សំនួរគំរូ៖</p>\r\n<ul>\r\n<li>តើការលូតលាស់របស់កុមារមានលក្ខណៈយ៉ាងដូចម្តេច?</li>\r\n<li>តើការលូតលាស់របស់គាត់/នាងមានលក្ខណៈដូចគ្នានឹងកុមារដ៏ទៃទៀតដែលមានអាយុស្របាលគ្នា រឺទេ?</li>\r\n<li>តើអ្នកព្រួយបារម្ភពីការលូតលាស់របស់កុមារនេះទេ? ទម្ងន់គាត់ដូចម្តេចដែរ? កម្ពស់គាត់ដូចម្តេចដែរ?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>ចូរធ្វើការប្រៀបធៀប ថាតើកុមារមានការលូតលាស់ល្អកំរិតណាបើធៀបទៅនឹងកុមារដែលមានអាយុស្របាលគ្នាហើយរស់នៅក្នុងតំបន់នោះ។</li>\r\n</ul>\r\n<p>&nbsp;</p>",
    "score_1_local_definition"=>"កុមារមានទម្ងន់ស្រាលខ្លាំង រឺមានកំពស់ទាបខ្លាំងបើធៀបទៅនឹងអាយុរបស់គាត់/ នាង។",
    "score_2_local_definition"=>"កុមារមានទម្ងន់ស្រាល កម្ពស់ទាបជាង ហើយ/ឬ មិនសូវស្វាហាប់ដូចកុមារផ្សេងទៀតដែលមានអាយុដូចគ្នានៅក្នុងសហគមន៍។",
    "score_3_local_definition"=>"កុមារ ហាក់ដូចជាកំពុងលូតលាស់ បាន ល្អ ប៉ុន្តែមិនសូវសកម្ម បើប្រៀបធៀបទៅនឹង កុមារ ផ្សេងៗទៀត ដែលមានអាយុដូចគ្នានៅក្នុងសហគមន៍។",
    "score_4_local_definition"=>"ទម្ងន់ កម្ពស់ និងភាពស្វាហាប់របស់កុមារ កំពុងលូតលាស់បានល្អ ទៅតាមអាយុរបស់គាត់ឬនាង។"
    },
    {
    "name"=>"2A",
    "identity"=>"Shelter",
    "description"=>"<p><u><strong>Domains : 2A (Shelter)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child has stable shelter that is safe, adequate and dry.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Where does the child live?</p>\r\n</li>\r\n<li>\r\n<p>Are there any difficulties with the house?</p>\r\n</li>\r\n<li>\r\n<p>Where does the child sleep?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Is the house adequate for the size of the family living in it?</p>\r\n</li>\r\n<li>\r\n<p>Is the house in need of repairs?</p>\r\n</li>\r\n<li>\r\n<p>Is the child's bedroom in the same level of repair as the rest of the house?</p>\r\n</li>\r\n<li>\r\n<p>Is the house safe for the child's needs, at their age and stage of development?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>13,
    "score_1_definition"=>"The child has no stable, adequate or safe place to live.",
    "score_2_definition"=>"The child lives in a place that needs major repairs, is overcrowded, inadequate, and/or does not protect him/her from the weather.",
    "score_3_definition"=>"The child lives in a place that needs some repairs, but is fairly adequate, dry and safe.",
    "score_4_definition"=>"The child lives in a place that is adequate, dry and safe.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ២ក (ជម្រក/លំនៅ ដ្ឋាន)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារមានជម្រកច្បាស់លាស់ ដែលមានភាពសមរម្យ ស្ងួត ហើយសុវត្ថិភាព។</p>\r\n<p>សំនួ រគំរូ៖</p>\r\n<ul>\r\n<li>តើកុមាររស់នៅកន្លែងណា?</li>\r\n<li>តើ មាន បញ្ហាលំបាក ឣ្វី ខ្លះ ទាក់ ទងនឹង ផ្ទះនេះ?</li>\r\n<li>តើកុមារគេងនៅកន្លែងណា?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>តើផ្ទះនេះមានទំហំធំល្មមសម្រាប់ចំនួនសមាជិកគ្រួសារកំពុងរស់នៅឬទេ?</li>\r\n<li>តើ ផ្ទះ នេះតម្រូវឲ្យ មាន ការ ជួសជុលដែរឬទេ?</li>\r\n<li>តើ កន្លែង គេង របស់ កុមារ មាន ស្ថានដូច ស្ថានភាពផ្ទះ ដែល ត្រូវ ជួសជុល?</li>\r\n<li>តើ ផ្ទះ មាន សុវត្ថិភាព សម្រាប់តម្រូវការរបស់ កុមារទៅតាម ឣាយុ និងដំណាក់កាល នៃការ ឣភិវឌ្ឍន៍របស់ពួកគេដែរឬទេ?</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារមិនមានកន្លែងស្នាក់នៅច្បាស់លាស់​ ​សមរម្យ និង សុវត្ថិភាព​ដើម្បីរស់នៅឡើយ។​",
    "score_2_local_definition"=>"កុមាររស់នៅក្នុងកន្លែងដែលត្រូវការជួសជុលជាចាំបាច់ ចង្អៀតពេក សភាពមិនសមរម្យ និង/ឬ មិនអាច​​​ការ​ពារ​គាត់/​នាង​បាន​ពីអាកាស​ធាតុ។",
    "score_3_local_definition"=>"កុមាររស់នៅក្នុងកន្លែងដែលត្រូវមានការជួសជុលខ្លះៗ​ ប៉ុន្តែទីនោះមាន​សភាព​សមរម្យល្មម ស្ងូត​ និងសុវត្ថិភាព។",
    "score_4_local_definition"=>"កុមារបានរស់នៅក្នុងកន្លែងដែលមានសភាពសមរម្យ ស្ងួត និងសុវត្ថិភាព។"
    },
    {
    "name"=>"2B",
    "identity"=>"Care",
    "description"=>"<p><u><strong>Domains : 2B (Care)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child has at least one adult (aged 18 or over) who provides consistent care, attention and support.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Who is the most important adult in the child's life?</p>\r\n</li>\r\n<li>\r\n<p>Who takes care of this child?</p>\r\n</li>\r\n<li>\r\n<p>When something exciting or fun happens, who does the child tell?</p>\r\n</li>\r\n<li>\r\n<p>Who does the child go to if he/she feel sad? Or worried?</p>\r\n</li>\r\n<li>\r\n<p>Who does the child go to if he/she is hurt?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>How do the child and adult interact?</p>\r\n</li>\r\n<li>\r\n<p>Do they seem to know one anther well?</p>\r\n</li>\r\n<li>\r\n<p>Is the relationship between the adult and the child appropriately affectionate?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>13,
    "score_1_definition"=>"The child is completely without the care of an adult and must fend for him or herself, or lives in a child-headed household.",
    "score_2_definition"=>"The child has no consistent adult in his/her life that provides love, attention and support.",
    "score_3_definition"=>"The child has an adult who provides care but who is limited by illness or age, or seems indifferent to the child.",
    "score_4_definition"=>"The child has a primary caregiver who is involved in his/her life and who protects nurtures him/her.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ២ខ (ការថែទាំ)</strong></span></p>\r\n<p>គោលបំណង៖&nbsp; កុមារមានមនុស្សពេញវ័យ (មានអាយុ ១៨ឆ្នាំ រី ចាស់ជាង) យ៉ាងហោចណាស់ម្នាក់ ដែលអាចផ្តល់ ការថែទាំខ្ជាប់ខ្ជួន យកចិត្តទុកដាក់ និងជួយគាំទ្រ។</p>\r\n<p>សំនួរគំរូ៖</p>\r\n<ul>\r\n<li>តើនរណាជាមនុស្សពេញវ័យដែលសំខាន់បំផុតនៅក្នុងជីវិតរបស់កុមារនេះ?</li>\r\n<li>តើនរណាជាអ្នកថែរក្សាកុមារនេះ?</li>\r\n<li>តើកុមារប្រាប់នរណា ពេលដែលមានអ្វីរំភើប ឬសប្បាយរីករាយកើតឡើង?</li>\r\n<li>តើកុមារប្រាប់នរណា ប្រសិនបើគាត់មានអារម្មណ៍មិនសប្បាយចិត្ត ឬមានការព្រួយបារម្ភ?</li>\r\n<li>តើកុមារប្រាប់នរណា ប្រសិនបើគាត់មានការឈឺចាប់?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>តើកុមារ និងមនុស្សពេញវ័យមានទំនាក់ទំនងចំពោះគ្នាទៅវិញទៅមកយ៉ាងដូចម្តេច?</li>\r\n<li>តើពួកគេមើលទៅហាក់ដូចជាស្គាល់គ្នាច្បាស់ដែររឺទេ?</li>\r\n<li>តើ ទំនាក់ ទំនង រវាងមនុស្ស ពេញ វ័យ និង កុមារបានបង្ហាញ ពីទំនាក់ទំនងដែលប្រកបដោយ ក្តីស្រឡាញ់ ដែរ រឺទែ?</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារគ្មានមនុស្សពេញវ័យមើលថែ ហើយត្រូវ ផ្គត់ផ្គង់ ដោយខ្លួនឯង ឬរស់នៅដោយដើរតួរជាមេគ្រួសារ។",
    "score_2_local_definition"=>"កុមារមិនមានមនុស្សពេញវ័យនៅខ្ជាប់ខ្ជួនក្នុងជីវិតរបស់គាត់/នាងដែលបានផ្តល់សេចក្តីស្រឡាញ់ យកចិត្តទុកដាក់ និងគាំទ្រ។",
    "score_3_local_definition"=>"កុមារមានមនុស្សពេញវ័យ ដែលអាចផ្តល់ការថែទាំចំពោះគាត់ ប៉ុន្តែការ ថែទាំនោះនៅមានកម្រិត ដោយសារជំងឺ អាយុ ឬដូចជាមិនអើពើជាមួយកុមារ។",
    "score_4_local_definition"=>"កុមារមានមនុស្សពេញវ័យជាអ្នកថែទាំ បឋម ដែលបានចូលរួមក្នុងជីវិត ហើយ ការពារ និងចិញ្ចឹមបីបាច់គាត់/ នាង។"
    },
    {
    "name"=>"3A",
    "identity"=>"Protection from Abuse and Exploitation",
    "description"=>"<p><u><strong>Domains : 3A (Protection from Abuse and Exploitation)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is safe from any abuse, neglect or exploitation.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does anyone hurt this child?</p>\r\n</li>\r\n<li>\r\n<p>Do you think the child feels safe?</p>\r\n</li>\r\n<li>\r\n<p>Does the child work for anyone outside the household?</p>\r\n</li>\r\n<li>\r\n<p>Does anyone else who knows the child think he/she is being hurt or abused by someone else?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the child have any marks or bruises that suggest abuse?</p>\r\n</li>\r\n<li>\r\n<p>Is the child withdrawn or scared? Does the child seem too busy for a child of his/her age?</p>\r\n</li>\r\n<li>\r\n<p>Does the child seem easily startled?</p>\r\n</li>\r\n<li>\r\n<p>Does the child demonstrate inappropriately sexualised behaviour?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>14,
    "score_1_definition"=>"The child is abused, sexually or physically, and/or is being subjected to the child labour or other exploitation.",
    "score_2_definition"=>"The child is neglected, given inappropriate work for his/her age, or is clearly not treated well in the household.",
    "score_3_definition"=>"There is some suspicion that the child may be neglected, over-worked, treated poorly, or otherwise mistreated.",
    "score_4_definition"=>"The child does not seem to be abused or neglected, does not do inappropriate work, and does not seem exploited in other ways.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ៣ក (ការការពារ ពីការរំលោភបំពាន និងការកេងប្រវ័ញ្ច)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារមានសុវត្ថិភាពពីការរំលោភបំពាន ភាពព្រងើយកន្តើយ រឺការកេងប្រវ័ញ្ច។</p>\r\n<p>សំនួរគំរូ៖</p>\r\n<ul>\r\n<li>តើមាននរណាធ្វើអោយកុមារនេះឈឺចាប់ រឺទេ?</li>\r\n<li>តើអ្នកគិតថាកុមារមានអារម្មណ៏សុវត្ថិភាព រឺទេ?</li>\r\n<li>តើកុមារធ្វើការសំរាប់នរណាម្នាក់នៅខាងក្រៅ ក្រៅពីគ្រួសារ រឺទេ?</li>\r\n<li>តើមាននរណាផ្សេងដឹងពីគំនិតរបស់កុមារថាគាត់/នាងកំពុងត្រូវបានគេធ្វើបាប ឬរំលោភបំពានដោយអ្នកដ៏ទៃផ្សេងទៀត រឺទេ?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>តើកុមារមានសញ្ញា ឬស្នាមជាំណាដែលអាចប្រាប់ពីការរំលោភបំពាន រឺទេ?</li>\r\n<li>តើកុមារចូលចិត្តនៅដាច់ឆ្ងាយពីគេ ឬភ័យខ្លាចដែរឬទេ? តើកុមារមើលទៅហាក់ដូចជារវល់ជាមួយការងារពេក បើប្រៀបធៀបទៅនិងកុមារដែលមានអាយុដូចគាត់/នាងដែរឬទេ?</li>\r\n<li>តើកុមារហាក់ដូចជាងាយភ្ញាក់កន្ទ្រាក់/ភ្ញាក់ផ្អើលរឺទេ?</li>\r\n<li>តើកុមារមានសំដែងចេញអកប្បកិរិយាផ្លូវភេទមិនសមរម្យដែររឺទេ?</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារត្រូវបានគេ រំលោភបំពានផ្លូវភេទ រឺ  ផ្លូវកាយ និង/រឺ ទទួលរងនូវការកេងប្រវ័ញ្ចលើកំលាំងពលកម្មកុមារ ឬសភាពកេងប្រវ័ញ្ចផ្សេងៗ។",
    "score_2_local_definition"=>"កុមារត្រូវបានគេព្រងើយកន្តើយ អោយធ្វើការដែលមិន​សមស្របទៅនឹងអាយុរបស់គាត់/នាង ឬមិន​ទទួលបានការ​ថែទាំ​ល្អពីក្រុមគ្រួសារ។",
    "score_3_local_definition"=>"​មានការសង្ស័យខ្លះៗបានបង្ហាញថា កុមារប្រហែលត្រូវបានគេព្រងើយកន្តើយ ឱ្យធ្វើការលើសកំណត់ មិនចិញ្ចឹមបីបាច់បានល្អ រឺត្រូវបានគេធ្វើបាប។",
    "score_4_local_definition"=>"កុមារហាក់ដូចជាមិនទទួលរងនូវការរំលោភបំពាន ព្រងើយកន្តើយ ធ្វើការងារមិនសមរម្យ ហើយមិនត្រូវបានកេងប្រវ័ញ្ចក្នុងផ្លូវណាមួយឡើយ។"
    },
    {
    "name"=>"3B",
    "identity"=>"Legal Protection",
    "description"=>"<p><u><strong>Domains : 3B (Legal Protection)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child has access to legal protection services as needed.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does this child have a birth certificate or registration?</p>\r\n</li>\r\n<li>\r\n<p>Does the family have a legal will?</p>\r\n</li>\r\n<li>\r\n<p>Has the child ever been refused any services because of legal status?</p>\r\n</li>\r\n<li>\r\n<p>Do you know any legal problems for the child (such as land grabbing)?</p>\r\n</li>\r\n<li>\r\n<p>Does this child have an adult to stand up for his/her legal rights and protection?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the caregiver seem to hesitate or worry when asked about the child's legal status?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>14,
    "score_1_definition"=>"The child has no access to any legal protection services and is being legally exploited.",
    "score_2_definition"=>"The child has no access to any legal protection and may be at risk of exploitation.",
    "score_3_definition"=>"The child has no access to legal protection services, but no protection is needed at this time.",
    "score_4_definition"=>"The child has access to legal protection as needed.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ៣ខ (ការគាំពារដោយប្រពន្ធ័ផ្លូវច្បាប់)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារអាចទទួលបានសេវាគាំពារផ្នែកច្បាប់តាមដែលគេត្រូវការ។</p>\r\n<p>សំនួរគំរូ</p>\r\n<ul>\r\n<li>តើកុមារនេះបានចុះបញ្ចីកំណើត ឬមានសំបុត្រកំណើត រឺទេ?</li>\r\n<li>តើក្រុមគ្រួសារមានសំបុត្របណ្តាំ រឺទេ?</li>\r\n<li>តើកុមារធ្លាប់ត្រូវបានគេបដិសេធមិនផ្តល់សេវាណាមួយ ដោយសារលក្ខខ័ណ្ឌផ្លូវច្បាប់ដែររឺទេ?</li>\r\n<li>តើអ្នកដឹងពីបញ្ហាផ្លូវច្បាប់ដែលទាក់ទងនិងកុមារដែររឺទេ (ឧទាហរណ៍ ដូចជាការរំលោភយកដីធ្លីជាដើម)?</li>\r\n<li>តើកុមារមានមនុស្សពេញវ័យដែលអាចតស៊ូមតិដើម្បីសិទ្ធិស្របច្បាប់និងការគាំពារសម្រាប់កុមារដែររឺទេ?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>តើអ្នកថែទាំហាក់ដូចជាស្ទាក់ស្ទើរ ឬព្រួយបារម្ភនៅពេលសួរអំពីស្ថានភាពផ្លូវច្បាប់របស់កុមារដែរឬទេ?</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារពុំទទួលបាន​សេវាការការពារផ្លូវច្បាប់ ហើយត្រូវបាន​កេងប្រវ័ញ្ចតាមផ្លូវច្បាប់។",
    "score_2_local_definition"=>"កុមារពុំទទួលបាន​សេវាការការពារផ្លូវច្បាប់ហើយអាចប្រឈមនឹងការកេងប្រវ័ញ្ច។",
    "score_3_local_definition"=>"កុមារមិនធ្លាប់ទទួលបានសេវាគាំពារតាមផ្លូវច្បាប់ទេ​ ពីព្រោះតម្រូវការនៃការពារនេះគឺមិនទាន់ចាំបាច់នៅឡើយ។",
    "score_4_local_definition"=>"កុមារទទួលបានការគាំពារខាងផ្លូវច្បាប់តាមដែលគេត្រូវការ។"
    },
    {
    "name"=>"4A",
    "identity"=>"Wellness",
    "description"=>"<p><u><strong>Domains : 4A (Wellness)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is physically healthy.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Tell me about this child's health.</p>\r\n</li>\r\n<li>\r\n<p>Tell me about the last sickness this child had.</p>\r\n</li>\r\n<li>\r\n<p>Has the child missed school or work recently because of illness?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong> Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the child seem to be active and generally healthy?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>15,
    "score_1_definition"=>"In the past month, the child has been ill most of the time (chronically ill).",
    "score_2_definition"=>"In the past month, the child was often (more than three days) ill for school, work or play.",
    "score_3_definition"=>"In the past month, the child was ill and less active for a few days (1-3) but he/she was able to take part in some normal activities.",
    "score_4_definition"=>"In the past month, the child has been healthy and active, with no fever, diarrhea, or other illness.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ៤ក (សុខមាលភាព)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារមានសុខភាពរាងកាយល្អ។</p>\r\n<p>សំនួរគំរូ</p>\r\n<ul>\r\n<li>សូមប្រាប់ខ្ញុំអំពីសុខភាពរបស់កុមារនេះ។</li>\r\n<li>សូមប្រាប់ខ្ញុំអំពីជម្ងឺដែលកុមារបានឈឺចុងក្រោយគេបង្អស់។</li>\r\n<li>តើកុមារខកខានមិនបានទៅសាលារៀន រឺធ្វើការ ដោយសារមានជម្ងឺនៅពេលថ្មីៗនេះរឺទេ?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>តើកុមារមើលទៅសកម្ម និងមានសុខភាពល្អជាធម្មតាដែរ រឺទេ?</li>\r\n</ul>",
    "score_1_local_definition"=>"ក្នុងខែមុន កុមារបានឈឺស្ទើរគ្រប់ពេល (ជំងឺប្រចាំកាយ)។",
    "score_2_local_definition"=>"ក្នុងខែមុន កុមារជាញឹកញាប់បានឈឺ(ច្រើនជាងបីថ្ងៃ) ហើយខកខានមិនបានទៅសាលា ធ្វើការ ឬ លេងបាន។",
    "score_3_local_definition"=>"ក្នុងខែមុន កុមារបានជំងឺ និងមិនសូវសកម្ម (រយៈពេល ពី១-៣ថ្ងៃ) ប៉ុន្តែគាត់/នាង នៅតែអាចចូលរួមសម្មភាពធម្មតាមួយចំនួនបាន។",
    "score_4_local_definition"=>"នៅខែមុន កុមារមានសុខភាពល្អ និង សកម្ម ដោយគ្មានជម្ងឺគ្រុនក្តៅ រាគ រឺជំងឺផ្សេងៗឡើយ។"
    },
    {
    "name"=>"4B",
    "identity"=>"Health Care Services",
    "description"=>"<p><u><strong>Domains : 4B (Health Care Services)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child can access health care services, including medical treatment when ill, and preventive care.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>What happens when this child gets sick?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she see a nurse, doctor or any other health professional?</p>\r\n</li>\r\n<li>\r\n<p>When he/she needs medicine, how does he/she get it?</p>\r\n</li>\r\n<li>\r\n<p>Has the child been immunised?</p>\r\n</li>\r\n<li>\r\n<p>Has anyone talked to the child about risks for the HIV/AIDS and how to protect against these risks?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>If possible, observe the child's immunisation card.</p>\r\n</li>\r\n<li>\r\n<p>Does the child has a mosquito net for their bed?</p>\r\n</li>\r\n<li>\r\n<p>What health services are available in the local area?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>15,
    "score_1_definition"=>"The child rarely or never received the necessary health care services.",
    "score_2_definition"=>"The child only sometimes or inconsistently receive needed health care services (treatment or preventive).",
    "score_3_definition"=>"The child receive medical treatment when ill, but some health care services (eg. immunisations) are not received.",
    "score_4_definition"=>"The child has received all or almost necessary health care treatment and preventive services.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ៤ខ (សេវាថែទាំសុខភាព)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារអាចទទួលបានសេវាថែទាំសុខភាព រួមទាំងការព្យាបាលដោយប្រើប្រាស់ថ្នាំ ពេទ្យពេលមានជំងឺ និងសេវាថែទាំបង្ការផ្សេងៗ។</p>\r\n<p>សំនួរគំរូ៖</p>\r\n<ul>\r\n<li>តើមានអ្វីកើតឡើងនៅពេលកុមារធ្លាក់ខ្លួនឈឺ?</li>\r\n<li>តើគាត់/នាងបានទៅជួបជាមួយគិលានុបដ្ឋាយិកា វេជ្ជបណ្ឌិត ឬអ្នកជំនាញខាង​សុខ​ភាព ​​រឺទេ?</li>\r\n<li>ពេលដែលគាត់/នាងត្រូវការថ្នាំពេទ្យ​តើគាត់/នាងទទួលបានថ្នាំដោយវីធីណា?</li>\r\n<li>(សំរាប់អាយុក្រោម៥ឆ្នាំ) តើកុមារមានបានចាក់ថ្នាំបង្ការដើម្បីការពារជម្ងឺហើយ រឺនៅ?</li>\r\n<li>(សម្រាប់មនុស្សជំទង់) តើមានអ្នកណាធ្លាប់បានណែនាំកុមារពីហានិភ័យ(គ្រោះថ្នាក់)នៃការឆ្លងមេរោគអេដស៍/ជំងឺអេដស៍ និងពីរបៀបការពារពីហានិភ័យ(គ្រោះថ្នាក់)ទាំងនេះដែររឺទេ?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>ប្រសិនបើអាច, សូមអង្កេតលើប័ណ្ណចាក់ថ្នាំបង្ការមេរោគរបស់កុមារ។</li>\r\n<li>តើកុមារមានមុងសម្រាប់គេងដែរឬទេ?</li>\r\n<li>តើមានសេវាសុខភាពអ្វីខ្លះដែលអាចរកបាននៅក្នុងតំបន់នោះ?</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារកម្រ ឬមិនដែលធ្លាប់ទទួលបានសេវាថែទាំសុខភាពដែលចាំបាច់។",
    "score_2_local_definition"=>"កុមារទទួលបានសេវាថែទាំសុខភាព​(ការព្យាបាល​ រឺ ថែទាំបង្ការ) ពុំខ្ជាប់ខ្ជួន ឬបានត្រឹមតែពេលខ្លះប៉ុណ្ណោះ។",
    "score_3_local_definition"=>"កុមារទទួលបានថ្នាំសម្រាប់ព្យាបាលនៅពេលឈឺ ប៉ុន្តែសេវាថែទាំសុខភាពខ្លះមិនទាន់ទទួលបាននៅឡើយទេ។",
    "score_4_local_definition"=>"កុមារបានទទួលទាំងអស់ ឬស្ទើរតែទាំងអស់នូវការព្យាបាលថែទាំសុខភាពដែលចាំបាច់​ និង សេវាបង្ការ​។"
    },
    {
    "name"=>"5A",
    "identity"=>"Emotional Health",
    "description"=>"<p><u><strong>Domains : 5A (Emotional Health)</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is happy and content with a generally positive and hopeful outlook.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Is the child usually happy or usually sad?</p>\r\n</li>\r\n<li>\r\n<p>How can you tell if the child is happy/unhappy?</p>\r\n</li>\r\n<li>\r\n<p>Do you worry about this child's sadness or grief?</p>\r\n</li>\r\n<li>\r\n<p>Have you ever thought the child did not want to live any more?</p>\r\n</li>\r\n<li>\r\n<p>Do you worry he/she might hurt her/himself?</p>\r\n</li>\r\n<li>\r\n<p>(Ask the child) Do you think you have a good life?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Does the child seem happy in the home?</p>\r\n</li>\r\n<li>\r\n<p>Is the child willing to talk to the visitor?</p>\r\n</li>\r\n<li>\r\n<p>Does the child's face express emotions?&nbsp;</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>16,
    "score_1_definition"=>"The child seems hopeless, sad, withdraw, wishes he/she could die, or want to be left alone. An infant refuses to eat, sleeps poorly, cries a lot.",
    "score_2_definition"=>"The child is often withdrawn, irritable, anxious, unhappy or sad. An infant may cry frequently or often be inactive.",
    "score_3_definition"=>"The child is mostly happy, but occasionally he/she is anxious, withdraw. An infant may be crying, or not sleeping well some of the time.",
    "score_4_definition"=>"The child seems happy, hopeful, and content.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ៥ក (សុខភាពផ្លូវចិត្ត)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារមានអារម្មណ៍សប្បាយរីករាយ នឹងពេញចិត្តជាមួយនឹងនិមិត្តដែលវិជ្ជមាននឹងពេញដោយក្តីសង្ឃឹម។</p>\r\n<p>សំនួរគំរូ៖</p>\r\n<ul>\r\n<li>តើកុមារ ជាទូទៅសប្បាយ រីករាយ ឬក៏ក្រៀមក្រំ?</li>\r\n<li>តើអ្នកអាចដឹងបានដោយរបៀបណា ប្រសិនបើគាត់/នាងមានអារម្មណ៏សប្បាយ ឬមិនសប្បាយចិត្ត?</li>\r\n<li>តើអ្នកព្រួយបារម្ភ អំពីភាពក្រៀមក្រំ ឬភាពសោកសៅរបស់កុមារនេះ រឺទេ?</li>\r\n<li>តើអ្នកធ្លាប់បានគិតទេថា កុមារមិនចង់មានជីវិតរស់នៅតទៅទៀតដែរ រឺទេ?</li>\r\n<li>តើអ្នកព្រួយបារម្ភពីគាត់/នាងអាចនឹងធ្វើបាបខ្លួនគាត់/នាងផ្ទាល់ រឺទេ?</li>\r\n<li>តើអ្នកគិតថាអ្នកមានជីវិតល្អឬទេ (សួរទៅកុមារ)?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>តើកុមារមើលទៅហាក់ដូចជាសប្បាយរីករាយក្នុង គ្រួសារ?</li>\r\n<li>តើ កុមារ ចង់និយាយលេងជាមួយភ្ញៀវ?</li>\r\n<li>តើទឹកមុខរបស់កុមារបានបង្ហាញចេញពីអារម្មណ៌អ្វីខ្លះ?</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារហាក់ដូចជាអស់សង្ឃឹម ក្រៀមក្រំ ដកខ្លួនចេញពីគេ ចង់ស្លាប់ ឬ ចង់អោយគេទុកចោលនៅម្នាក់ឯង។ សំរាប់ទារកបដិសេធក្នុងការញុំាអាហារ គេងមិនបានស្កប់ស្កល់ ឬយំច្រើន។",
    "score_2_local_definition"=>"កុមារជាញឹកញាប់នៅដាច់ឆ្ងាយពីគេ ឆាប់ខឹង ខ្វល់ខ្វាយ មិនសប្បាយចិត្ត ឬក្រៀមក្រំ។ ទារកអាចយំច្រើន ឬ អសកម្ម។",
    "score_3_local_definition"=>"កុមារ ភាគច្រើនរីករាយ ប៉ុន្តែម្តងម្កាលមានអារមណ៍រខ្វល់ខ្វាយ ឬគេចចេញពីគេ។ ទារកប្រហែលអាចយំ ឬគេងពុំសូវលក់ស្រួលនៅពេលខ្លះ។",
    "score_4_local_definition"=>"កុមារ មើលទៅមានភាពរីករាយ ពេញដោយក្តីសង្ឃឹម និងសប្បាយចិត្ត។"
    },
    {
    "name"=>"5B",
    "identity"=>"Social Behaviour",
    "description"=>"<p><u><strong>Domain: 5B Social Behavior</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child cooperates and enjoys participating in activities with adults and other children.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>What is the child's behaviour like toward adults? Is he/she obedient?</p>\r\n</li>\r\n<li>\r\n<p>Does the child need to be punished or disciplined often?</p>\r\n</li>\r\n<li>\r\n<p>Does the child play with other children or have close friends? Does he/she enjoy being with other children?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she fight with other children?</p>\r\n</li>\r\n<li>\r\n<p>Do you worry about the child having problems with others at school?</p>\r\n</li>\r\n<li>\r\n<p>How does the child react with the CCW?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>16,
    "score_1_definition"=>"The child has behavioral problems, including stealing, early sexual activity, and/ or other disruptive behavior.",
    "score_2_definition"=>"The child disobedient to adults, and often does not interact with peers, guardian, or other at home or school.",
    "score_3_definition"=>"The child has minor problems getting along with others and argues or get into fight sometimes.",
    "score_4_definition"=>"The child likes to play with peers and anticipates with group or family activities.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ៥ខ (អាកប្បកិរិយាក្នុងសង្គម)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារសហការណ៍ ហើយសប្បាយរីករាយក្នុងការចូលរួមធ្វើសកម្មភាពជាមួយមនុស្សពេញវ័យ នឹងកុមារផ្សេងៗទៀត។</p>\r\n<p>សំនួរគំរូ៖</p>\r\n<ul>\r\n<li>តើអកប្បកិរិយារបស់គាត់/នាងប្រព្រឹត្តចំពោះមនុស្សពេញវ័យដូចម្តេច? តើគាត់/នាងស្តាប់បង្គាប់ រឺ ទេ?</li>\r\n<li>តើកុមារនេះត្រូវបានដាក់ទណ្ឌកម្ម ឬដាក់វិន័យជាញឹកញាប់ដែរ រឺទេ?</li>\r\n<li>តើកុមារមានលេងជាមួយក្មេងដ៏ទៃទៀត ឬមានមិត្តភ័ក្តិជិតស្និតដែរ រឺទេ? ប្រសិនបើមាន, តើគាត់/ នាង រីករាយលេងជាមួយអ្នកដ៏ទៃទៀតដែរ រឺទេ?</li>\r\n<li>តើគាត់/នាងវាយតប់ជាមួយក្មេងដ៏ទៃទៀត រឺទេ?</li>\r\n<li>តើអ្នកព្រួយបារម្ភថា កុមារអាចមានបញ្ហាជាមួយកុមារផ្សេងទៀតនៅសាលារៀនដែររឺទេ?</li>\r\n<li>តើកុមារមានប្រតិកម្មជាមួយបុគ្គលិកគ្រប់គ្រងករណីក្នុងសហគមន៌យ៉ាងដូមម្តេច?</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារមានបញ្ហាលើអាកប្បកិរិយាដូចជាការលួច សកម្មភាពផ្លូវភេទមុនអាយុ និង/ឬ អាកប្បកិរិយារំខានគេ។",
    "score_2_local_definition"=>"កុមារមិនស្តាប់បង្គាប់មនុស្សចាស់ និង ជាញឹកញាប់មិនចុះ សម្រុងជាមួយកុមារៗស្រករគ្នា អាណាព្យាបាល ឬ អ្នកដ៏ទៃ ទៀត នៅក្នុងគ្រួសារ រឺ នៅសាលា។",
    "score_3_local_definition"=>"កុមារមានបញ្ហាតិចតួចក្នុងការចុះសំរុងជាមួយអ្នកដ៍ទៃ ហើយពេលខ្លះមានជំលោះ ឬ ឈានដល់ការវាយតប់គ្នា។",
    "score_4_local_definition"=>"កុមារចូលចិត្តលេងជាមួយក្មេងៗដូចគ្នា និងចូលរួមសកម្មផ្សេងៗក្នុងក្រុម ឬ គ្រួសារ។"
    },
    {
    "name"=>"6A",
    "identity"=>"Performance",
    "description"=>"<p><span style=\"text-decoration: underline;\"><strong>Domains : 6A (Performance)</strong></span></p>\r\n<p>&nbsp;</p>\r\n<p>Goal: The child is progress well in acquiring knowledge and skills at home, school, job, training, or an age-appropriate productive activity.</p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Is this child developing as you would expect?</p>\r\n</li>\r\n<li>\r\n<p>Is this child learning new things, as you would expect of others his/her age?</p>\r\n</li>\r\n<li>\r\n<p>Do you worry about this child's performance or learning?</p>\r\n</li>\r\n<li>\r\n<p>Is the child quick to understand and learn?</p>\r\n</li>\r\n<li>\r\n<p>Do teachers report that child is doing well at school?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she do a good job with chores at home, such as work in the garden?</p>\r\n</li>\r\n<li>\r\n<p>Is the child advancing to the next grade as expected?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>If an adolescent, ask the child about skills training and learning skill that are useful for him/her.</p>\r\n</li>\r\n<li>\r\n<p>If in school, observe the response if ask about class performance and ranking</p>\r\n</li>\r\n<li>\r\n<p>If the child is 5 years old or younger, observe the child development or progress (in language, in movement, in learning) and compare this to what you expect for children of the same age.</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>17,
    "score_1_definition"=>"The child has serious problems with performance and learning in life or developmental skills.",
    "score_2_definition"=>"The child is gaining skill poorly and/or is falling behind. An infant or preschool child is gaining skills more slowly than his/her peers",
    "score_3_definition"=>"The child is learning well and developing life skills fairly well, but caregivers, teachers and other leaders have some concern about progress.",
    "score_4_definition"=>"The child is learning well, developing life skills, and progressing as expected by caregivers, teachers or other leaders.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ៦ក (ការប្រព្រឹត្ត)</strong></span></p>\r\n<p>គោលបំណង៖ កុមារកំពុងរីកចម្រើនយ៉ាងល្អកុមារការក្រេបយកចំណេះដឹង នឹងផ្នែកបំណិតជិវិតទាំងពេលនៅផ្ទះ នៅសាលា ក្នុងវគ្គបណ្តុះបណ្តាល ក្នុងការងារ ឬសកម្មភាពផ្សេងៗទៀតដែលផ្តល់ប្រយោជន៍សមស្របតាមអាយុគាត់។</p>\r\n<p>សំនួរគំរូ៖</p>\r\n<ul>\r\n<li>តើកុមារនេះកំពុងរីកចម្រើនលូតលាស់ដូចអ្វីដែលអ្នករំពឹងទុករឺទេ?</li>\r\n<li>តើកុមារនេះកំពុងរៀនអ្វីថ្មីៗដូចដែលអ្នករំពឹងទុកដូចនឹងកុមារផ្សេងៗទៀតដែលមានអាយុស្របាលគាត់/នាងដែររឺទេ?</li>\r\n<li>តើអ្នកព្រួយបារម្ភអំពីការប្រព្រឹត្ត ឬការសិក្សារបស់កុមារនេះ រឺទេ?</li>\r\n<li>តើកុមារឆាប់យល់ និងរៀនសូត្របានលឿនដែរ រឺទេ?</li>\r\n<li>តើលោកគ្រូ/អ្នកគ្រូមានរាយការណ៍អំពីការធ្វើល្អៗរបស់កុមារនៅសាលារៀន រឺទេ?</li>\r\n<li>តើគាត់/នាងធ្វើកិច្ចការផ្ទះបានល្អ រឺទេ? ឧទារហ៏ ដូចជា ការថែទាំសួនជាដើម។</li>\r\n<li>តើកុមារនឹងឡើងថ្នាក់ដូចអ្វីដែលបានរំពឹងទុកដែរទេ?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>ប្រសិនបើកុមារនេះមានវ័យជំទង់ សូមសួរកុមារអំពីវគ្គបណ្តុះបណ្តាល និងការរៀនជំនាញដែលមានប្រយោជន៍ដល់គាត់/នាង។</li>\r\n<li>ប្រសិនបើគាត់/នាងកំពុងនៅសិក្សា សូមសង្កេតលើការឆ្លើយតប នៅពេលដែលអ្នកសួរសំនួរអំពីចំណាត់ថា្នក់ និងការប្រព្រឹត្តនៅក្នុងថ្នាក់រៀនរបស់គាត់។</li>\r\n<li>ប្រសិនបើកុមារមានអាយុ៥ឆ្នាំ ឬក្មេងជាង ធ្វើការសង្កេតលើដំណើរការនៃការលូតលាស់របស់កុមារ (ឧ. ភាសា, ចលនា, ការរៀនសូត្រ) ហើយធ្វើការប្រៀបធៀបទៅនឹងការរំពឹងទុករបស់អ្នក សម្រាប់កុមារដែលមានអាយុស្រករគ្នា។</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារមានបញ្ហាធ្ងន់ធ្ងរក្នុងការប្រព្រឹត្ត និងការសិក្សាក្នុងជីវិត ឬក៏ជំនាញអភិវឌ្ឍន៍។",
    "score_2_local_definition"=>"កុមារមានការរីកចំរើនផ្នែកជំនាញយឹឺតយ៉ាវ និង/ឬ រៀនតាមពីក្រោយគេ។ ទារក ឬកុមារដែលសិក្សានៅថ្នាក់មត្តេយ្យកម្រិតទាប គាត់/នាងមានការរីកចំរើនផ្នែកជំនាញយឹឺតជាងកុមារដ៏ទៃទៀត។",
    "score_3_local_definition"=>"កុមារកំពុងរៀនសូត្របានយ៉ាងល្អ និង​អភិវឌ្ឍបំណិនជីវិតល្អគួសម ប៉ុន្តែអ្នកថែទាំ គ្រូបង្រៀន ឬ អ្នកដឹកនាំផ្សេងទៀត មានការព្រួយបារម្ភខ្លះៗពីភាពរីកចម្រើនរបស់ពួកគាត់។​",
    "score_4_local_definition"=>"កុមារកំពុងសិក្សាររៀនសូត្របានយ៉ាងល្អ បំណិនជីវិតក៏កំពុងលូតលាស់ ហើយរីកចម្រើនដូចការរំពឹងទុករបស់អាណាព្យាបាល គ្រូបង្រៀន រឺ អ្នកដឹកនាំផ្សេងៗទៀត។"
    },
    {
    "name"=>"6B",
    "identity"=>"Work and Education",
    "description"=>"<p><u><strong>Domain: 6B Education and Work</strong></u></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Goal: The child is enrolled and attends school, or skill training, or is engaged in age-appropriate play, learning, activities or job.</strong></p>\r\n<p>&nbsp;</p>\r\n<p><strong>Sample Questions:</strong></p>\r\n<ul>\r\n<li>\r\n<p>Is the child in, or has he/she completed, primary school?</p>\r\n</li>\r\n<li>\r\n<p>Tell me about the child's school or training</p>\r\n</li>\r\n<li>\r\n<p>Who pays school fee and buys uniforms and school materials?</p>\r\n</li>\r\n<li>\r\n<p>Does the child attend the school regularly?</p>\r\n</li>\r\n<li>\r\n<p>How often must the child miss school for any reason?</p>\r\n</li>\r\n<li>\r\n<p>Does he/she go to work regularly?</p>\r\n</li>\r\n</ul>\r\n<p>&nbsp;</p>\r\n<p><strong>Things to look for during the visit:</strong></p>\r\n<ul>\r\n<li>\r\n<p>If possible, observe the child's school uniform, or supplies, or their usage</p>\r\n</li>\r\n<li>\r\n<p>If an infant or preschooler, observe if he/she is involved in any play or learning with any family member?</p>\r\n</li>\r\n</ul>",
    # "domain_group_id"=>17,
    "score_1_definition"=>"The child is not enrolled in school, not attending training, or not involve in an age-appropriate productive activity or job. An infant or preschooler is not played with.",
    "score_2_definition"=>"The child is enrolled in school or has a job, but he/she rarely attends. An infant or preschooler is rarely played with.",
    "score_3_definition"=>"The child is enrolled in school or training, but attends irregularly or shows up inconsistently for it, or for a productive activity or job. Younger children are played with sometimes, but not daily.",
    "score_4_definition"=>"The child is enrolled in and attending school/ training regularly. Infants/preschoolers play with their caregiver. An older child has an appropriate job.",
    "local_description"=>"<p><span style=\"text-decoration: underline;\"><strong>កត្តា៖ ៦ខ ការអប់រំ នឹងការងារ</strong></span></p>\r\n<p>គោលបំណង៖ កុមារបានចុះឈ្មោះ ហើយចូលរៀនក្នុងសាលា ឬវគ្គបណ្តុះបណ្តាលជំនាញ ឬ ត្រូវបានគេឲ្យចូលរូមលេង រៀន សកម្មភាពផ្រេងៗ ឬការងារតាមអាយុសមស្របរបស់ពួកគេ។</p>\r\n<p>សំនួរគំរូ៖</p>\r\n<ul>\r\n<li>តើកុមារ (គាត់/នាង)បានរៀនចប់ថ្នាក់បមឋសិក្សាហើយ រឺក៏នៅកំពុងសិក្សា?</li>\r\n<li>សូមប្រាប់ខ្ញុំអំពីសាលារៀន ឬវគ្គបណ្តុះបណ្តាលរបស់កុមារ។</li>\r\n<li>តើនរណាជាអ្នកបង់ថ្លៃសាលា ទិញឯកសណ្ឋាននឹងសម្ភារសិក្សា?</li>\r\n<li>តើកុមារបានទៅរៀនទៀងទាត់ដែររឺទេ?</li>\r\n<li>តើញឹកញាប់ប៉ុណ្ណាដែលកុមារត្រូវខកខានមិនបានទៅសាលារៀនដោយហេតុផលណាមួយ?</li>\r\n<li>តើគាត់/នាងបានទៅធ្វើការទៀងទាត់ទេ?</li>\r\n</ul>\r\n<p>ចំនុចដែលត្រូវសង្កេតមើលអំឡុងជំនួប៖</p>\r\n<ul>\r\n<li>ប្រសិនបើអាច សូមធ្វើការសង្កេតលើឯកសណ្ឋានសាលារបស់កុមារ ឬសម្ភារៈ និងការប្រើ ប្រាស់ របស់ពួកគេលើរបស់ទាំងនោះ។</li>\r\n<li>ប្រសិនជាទារក ឬកុមារថ្នាក់មត្តេយ្យកម្រិតទាប សូមសង្កេតទៅលើសកម្មភាពរបស់គាត់/ នាង ថាបាន ចូលរួមលេងអ្វីមួយ ឬកំពុង រៀនសូត្រជាមូយសមាជិកគ្រួសារណាមួយ ឬទេ?</li>\r\n</ul>",
    "score_1_local_definition"=>"កុមារមិនត្រូវបានយកទៅចុះឈ្មោះចូលរៀន ចូលរួមវគ្គបណ្តុះបណ្តាល ចូលរួមក្នុងសកម្មភាព ឬការងារណាមួយដែលមានប្រយោជន៍ ស័ក្តិសមនឹងអាយុរបស់គាត់ទេ។ ទារក រឺកុមារនៅថ្នាក់មត្តេយ្យកម្រិតទាបមិនមានអ្នកលេងជាមួយ។",
    "score_2_local_definition"=>"កុមារបានចុះឈ្មោះចូលរៀន ឬមានការងារ ប៉ុន្តែគាត់/នាងមិនសូវបានទៅសាលា ឬធ្វើការណាស់។ ទារក រឺកុមារនៅថ្នាក់មត្តេយ្យកម្រិតទាបមិនសូវមានអ្នកលេងជាមួយ។",
    "score_3_local_definition"=>"កុមារបានចុះឈ្មោះចូលរៀន /វគ្គបណ្តុះ បណ្តាល ប៉ុន្តែមិនបានចូលរៀន ឬបង្ហាញខ្លួនទៀង ទាត់ក្នុងការសិក្សា ឬ សកម្មភាព/ការ ងារដែលមានប្រយោជន៍។ ពេលខ្លះ កុមារមានគេលេង ជា មួយ ប៉ុន្តែមិន ជារៀងរាល់ថ្ងៃ។",
    "score_4_local_definition"=>"កុមារបានចុះឈ្មោះចូលរៀន និង ចូល រួមវគ្គ បណ្តុះ បណ្តាល ទៀងទាត់។ ទារក រឺកុមារ ដែល រៀននៅ ថ្នាក់មត្តេយ្យកម្រិតទាបអាចលេងជាមួយអ្នកថែទាំបាន។ កុមារ ដែលធំ ជាងត្រូវមានការងារដែលសមស្រប។"
    }
  ]
end
