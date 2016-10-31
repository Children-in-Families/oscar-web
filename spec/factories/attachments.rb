FactoryGirl.define do
  factory :attachment do
    able_screening_question nil
    after :create do |a|
      a.update_column(:image, 'chrome.png')
    end
  end
end
