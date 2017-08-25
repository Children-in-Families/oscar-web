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

  def succeed_in_visiting(feature, object)
    visit "/#{feature.pluralize}"
    expect(current_path).to eq("/#{feature.pluralize}")

    visit "/#{feature.pluralize}/new"
    expect(current_path).to eq("/#{feature.pluralize}/new")

    visit "/#{feature.pluralize}/#{object.id}/edit"
    expect(current_path).to eq("/#{feature.pluralize}/#{object.id}/edit")

    visit "/#{feature.pluralize}/#{object.id}"
    expect(current_path).to eq("/#{feature.pluralize}/#{object.id}")
  end

  def failed_to_visit(feature, object)
    visit "/#{feature.pluralize}"
    expect(current_path).to eq('/users/sign_in')

    visit "/#{feature.pluralize}/new"
    expect(current_path).to eq('/users/sign_in')

    visit "/#{feature.pluralize}/#{object.id}/edit"
    expect(current_path).to eq('/users/sign_in')

    visit "/#{feature.pluralize}/#{object.id}"
    expect(current_path).to eq('/users/sign_in')
  end

  def visit_links_for_readonly_user(feature, object)
    visit "/#{feature.pluralize}"
    expect(current_path).to eq('/families')

    visit "/#{feature.pluralize}/new"
    expect(current_path).to eq('/users/sign_in')

    visit "/#{feature.pluralize}/#{object.id}/edit"
    expect(current_path).to eq('/users/sign_in')

    visit "/#{feature.pluralize}/#{object.id}/version"
    expect(current_path).to eq("/families/#{family.id}/version")

    visit "/#{feature.pluralize}/#{object.id}"
    expect(current_path).to eq("/families/#{family.id}")
  end
end
