FactoryGirl.define do
  factory :attachment do
    after :create do |a|
      a.update_column(:image, 'chrome.png')
    end
  end
end
