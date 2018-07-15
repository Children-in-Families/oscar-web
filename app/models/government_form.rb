class GovernmentForm < ActiveRecord::Base
  has_paper_trail

  belongs_to :client
  belongs_to :province
  belongs_to :district
  belongs_to :commune
  belongs_to :village

  has_many :government_form_interviewees, dependent: :destroy
  has_many :interviewees, through: :government_form_interviewees
  has_many :client_type_government_forms, dependent: :restrict_with_error
  has_many :client_types, through: :client_type_government_forms
  has_many :government_form_needs, dependent: :restrict_with_error
  has_many :needs, through: :government_form_needs
  has_many :government_form_problems, dependent: :restrict_with_error
  has_many :problems, through: :government_form_problems

  accepts_nested_attributes_for :government_form_needs
  accepts_nested_attributes_for :government_form_problems

  # pending
  # before_validation :concat_client_code_with_village_code

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

  def self.filter(options)
    records = all
    records.where(name: options[:name]) if options[:name].present?
  end

  # private

  # def concat_client_code_with_village_code
  #   self.client_code
  # end
end
