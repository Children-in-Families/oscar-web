class GovernmentForm < ActiveRecord::Base
  has_paper_trail

  belongs_to :client

  has_many :government_form_interviewees, dependent: :destroy
  has_many :interviewees, through: :government_form_interviewees
  has_many :client_type_government_forms, dependent: :restrict_with_error
  has_many :client_types, through: :client_type_government_forms
  has_many :government_form_needs, dependent: :restrict_with_error
  has_many :needs, through: :government_form_needs
  has_many :government_form_problems, dependent: :restrict_with_error
  has_many :problems, through: :government_form_problems
  has_many :government_form_children_plans, dependent: :restrict_with_error
  has_many :children_plans, through: :government_form_children_plans
  has_many :government_form_family_plans, dependent: :restrict_with_error
  has_many :family_plans, through: :government_form_family_plans

  accepts_nested_attributes_for :government_form_needs
  accepts_nested_attributes_for :government_form_problems
  accepts_nested_attributes_for :government_form_children_plans
  accepts_nested_attributes_for :government_form_family_plans

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
      government_form_children_plans.build(children_plan: plan)
    end
  end

  def populate_family_plans
    FamilyPlan.all.each do |plan|
      government_form_family_plans.build(family_plan: plan)
    end
  end

  # validates :client, presence: true

#   delegate :name, :slug, :gender, :date_of_birth, :initial_referral_date, to: :client, prefix: true

#   def carer_name
#     client.cases.current.try(:carer_names)
#   end

#   def carer_capital
#     client.cases.current.try(:province).try(:name)
#   end

#   def carer_phone_number
#     client.cases.current.try(:carer_phone_number)
#   end

#   def referral_name
#     client.referral_source.try(:name)
#   end
  def self.filter(options)
    records = all
    records.where(name: options[:name]) if options[:name].present?
  end

  def case_worker_name
    User.find_by(id: case_worker_id).try(:name)
  end
end
