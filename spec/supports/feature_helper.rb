module FeatureHelper
  def progress_note_info
    expect(page).to have_content(progress_note.decorate.client)
    expect(page).to have_content(progress_note.decorate.user)
    expect(page).to have_content(progress_note.decorate.user)
    expect(page).to have_content(progress_note.decorate.progress_note_type)
    expect(page).to have_content(progress_note.decorate.location)
    expect(page).to have_content(progress_note.other_location)
    expect(page).to have_content(progress_note.interventions.pluck(:action).join(', '))
    expect(page).to have_content(progress_note.decorate.material)
    expect(page).to have_content(progress_note.assessment_domains.pluck(:goal).join(', '))
  end
end
