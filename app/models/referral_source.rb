class ReferralSource < ActiveRecord::Base
  has_many :clients, dependent: :restrict_with_error
  has_paper_trail
  REFERRAL_SOURCES = ['ក្រសួង សអយ/មន្ទីរ សអយ', 'អង្គការមិនមែនរដ្ឋាភិបាល', 'មន្ទីរពេទ្យ', 'នគរបាល', 'តុលាការ/ប្រព័ន្ធយុត្តិធម៌', 'រកឃើញនៅតាមទីសាធារណៈ', 'ស្ថាប័នរដ្ឋ', 'មណ្ឌលថែទាំបណ្ដោះអាសន្ន', 'ទូរស័ព្ទទាន់ហេតុការណ៍', 'មកដោយខ្លួនឯង', 'គ្រួសារ', 'មិត្តភក្ដិ', 'អាជ្ញាធរដែនដី', 'ផ្សេងៗ'].freeze
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :restrict_update, on: :update
  before_destroy :restrict_delete

  private
    def restrict_update
      if REFERRAL_SOURCES.include?(name_was)
        errors.add(:base, 'Referral Source cannot be updated')
      end
    end

    def restrict_delete
      if REFERRAL_SOURCES.include?(self.name)
        errors.add(:base, 'Referral Source cannot be deleted')
      end
    end
end
