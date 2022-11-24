FactoryBot.define do
  factory :task_progress_note do
    progress_note { "MyText" }
    progress_note_date { "2022-06-24" }
    task_id { 1 }
  end
end
