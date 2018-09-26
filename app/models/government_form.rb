class GovernmentForm < ActiveRecord::Base
  has_paper_trail

  CASEWORKER_ASSUMPTIONS = ['អាចធ្វើសមាហរណកម្មបាន', 'មិនអាចធ្វើសមាហរណកម្មបានទេ', 'បន្តករណី', 'បិទករណី']
  CONTACT_TYPES          = ['ជួបផ្ទាល់', 'តាមទូរសព្ទ', 'សរសេរ']
  CLIENT_DECISIONS       = ['ទទួលយកសេវា', 'មិនទទួលយកសេវា']

  belongs_to :client
  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :village
  belongs_to :case_closure
  belongs_to :interview_province, class_name: 'Province', foreign_key: 'interview_province_id'
  belongs_to :interview_district, class_name: 'District', foreign_key: 'interview_district_id'
  belongs_to :interview_commune, class_name: 'Commune', foreign_key: 'interview_commune_id'
  belongs_to :interview_village, class_name: 'Village', foreign_key: 'interview_village_id'
  belongs_to :assessment_province, class_name: 'Province', foreign_key: 'assessment_province_id'
  belongs_to :assessment_district, class_name: 'District', foreign_key: 'assessment_district_id'
  belongs_to :assessment_commune, class_name: 'Commune', foreign_key: 'assessment_commune_id'
  belongs_to :primary_carer_province, class_name: 'Province', foreign_key: 'primary_carer_province_id'
  belongs_to :primary_carer_district, class_name: 'District', foreign_key: 'primary_carer_district_id'
  belongs_to :primary_carer_commune, class_name: 'Commune', foreign_key: 'primary_carer_commune_id'
  belongs_to :primary_carer_village, class_name: 'Village', foreign_key: 'primary_carer_village_id'

  has_many :government_form_interviewees, dependent: :destroy
  has_many :interviewees, through: :government_form_interviewees
  has_many :client_type_government_forms, dependent: :destroy
  has_many :client_types, through: :client_type_government_forms
  has_many :government_form_needs, dependent: :destroy
  has_many :needs, through: :government_form_needs
  has_many :government_form_problems, dependent: :destroy
  has_many :problems, through: :government_form_problems
  has_many :government_form_children_plans, dependent: :destroy
  has_many :children_plans, through: :government_form_children_plans
  has_many :children_statuses, class_name: 'ChildrenPlan', through: :government_form_children_plans
  has_many :family_statuses, class_name: 'FamilyPlan', through: :government_form_family_plans
  has_many :government_form_family_plans, dependent: :destroy
  has_many :family_plans, through: :government_form_family_plans
  has_many :government_form_service_types, dependent: :destroy
  has_many :service_types, through: :government_form_service_types
  has_many :client_right_government_forms, dependent: :destroy
  has_many :client_rights, through: :client_right_government_forms
  has_many :action_results, dependent: :destroy

  accepts_nested_attributes_for :action_results, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :government_form_needs
  accepts_nested_attributes_for :government_form_problems
  accepts_nested_attributes_for :government_form_children_plans
  accepts_nested_attributes_for :government_form_family_plans

  delegate :code, to: :village, prefix: true, allow_nil: true
  delegate :name, to: :case_closure, prefix: true, allow_nil: true

  before_save :concat_client_code_with_village_code

  def populate_needs
    Need.all.each do |need|
      government_form_needs.build(need: need)
    end
  end

  def populate_problems
    Problem.all.each do |problem|
      government_form_problems.build(problem: problem)
    end
  end

  def populate_children_plans
    ChildrenPlan.all.each do |plan|
      next if plan.name == "តម្រូវការជំនួយផ្នែកច្បាប់"
      government_form_children_plans.build(children_plan: plan)
    end
  end

  def populate_children_status
    ChildrenPlan.all.each do |status|
      government_form_children_plans.build(children_status: status)
    end
  end

  def populate_family_plans
    form_three = ['ការការពារ និងការថែទាំ', 'ភាពស្និទ្ធស្នាលរវាងកុមារនិងអ្នកថែទាំ', 'សុខភាពផ្លូវកាយ', 'សុខភាពផ្លូវចិត្ត', 'ឆន្ទៈក្នុងការធ្វើឲ្យស្ថានភាពបានប្រសើរឡើង', 'មុខរបរ និងជំនាញនានាដែលអាចរកចំណូលបាន', 'ចំណេះដឹងទូទៅក្នុងសង្គម', 'ធនធាននានា(ដីធ្លី ផ្ទះ...)', 'ជំនួយពីសាច់ញាតិ', 'ការគាំទ្រពីសហគមន៍', 'កូនៗផ្សេងទៀតដែលអាចជួយបាន', 'ផ្សេងៗ']
    FamilyPlan.where(name: form_three).order(:priority).each do |plan|
      government_form_family_plans.build(family_plan: plan)
    end
  end

  def populate_family_status(form)
    form_two = ['ការការពារ និងការថែទាំ', 'ភាពស្និទ្ធស្នាលរវាងកុមារនិងអ្នកថែទាំ', 'សុខភាពផ្លូវកាយ', 'សុខភាពផ្លូវចិត្ត', 'ឆន្ទៈក្នុងការធ្វើឲ្យស្ថានភាពបានប្រសើរឡើង', 'មុខរបរ និងជំនាញនានាដែលអាចរកចំណូលបាន', 'កម្រិតសិក្សាអប់រំ', 'ធនធាននានា(ដីធ្លី ផ្ទះ...)', 'ជំនួយពីសាច់ញាតិ', 'ការគាំទ្រពីសហគមន៍', 'កូនៗផ្សេងទៀតដែលអាចជួយបាន', 'ផ្សេងៗ']
    form_six = ['ការការពារ និងការថែទាំ', 'ភាពស្និទ្ធស្នាលរវាងកុមារនិងអ្នកថែទាំ', 'សុខភាពផ្លូវកាយ', 'ឆន្ទៈនិងលទ្ធភាពក្នុងការបន្តធ្វើឲ្យស្ថានភាពបានប្រសើរឡើង', 'មុខរបរ និងជំនាញនានាដែលអាចរកចំណូលបាន', 'ទំនាក់ទំនងក្នុងសង្គម', 'ធនធាននានា(ដីធ្លី ផ្ទះ...)', 'ជំនួយពីសាច់ញាតិ (ទោះបីមានពិន្ទុតិចជាង២ក៏អាចបិទបានដែរ)', 'ការគាំទ្រពីសហគមន៍', 'កូនៗផ្សេងទៀតដែលអាចជួយបាន', 'ផ្សេងៗ']
    form = form == 'two' ? form_two : form_six
    FamilyPlan.where(name: form).order(:priority).each do |status|
      government_form_family_plans.build(family_status: status)
    end
  end

  def populate_case_closures
    CaseClosure.all.each do |case_closure|
      government_form_case_closures.build(case_closure: case_closure)
    end
  end

  def self.filter(options)
    records = all
    records.where(name: options[:name]) if options[:name].present?
  end

  def case_worker_info
    User.find_by(id: case_worker_id)
  end

  private

  def concat_client_code_with_village_code
    self.client_code = "#{village.try(:code)}#{client_code}"
  end
end
