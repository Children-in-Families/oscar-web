feature 'able screening question' do
  let!(:admin) { create(:user, roles: 'admin') }
  let!(:manager) { create(:user, roles: 'manager') }
  let!(:ec_manager) { create(:user, roles: 'ec manager') }
  let!(:fc_manager) { create(:user, roles: 'fc manager') }
  let!(:kc_manager) { create(:user, roles: 'fc manager') }
  let!(:able_manager) { create(:user, roles: 'able manager') }
  let!(:strategic_overviewer) { create(:user, roles: 'strategic overviewer') }
  let!(:case_worker) { create(:user, roles: 'case worker') }

  let!(:able_screening_question) { create(:able_screening_question) }

  scenario 'login as admin' do
    login_as(admin)

    visit new_able_screens_question_submissions_able_screening_question_path
    expect(current_path).to eq('/able_screening_questions/new')

    visit edit_able_screens_question_submissions_able_screening_question_path(able_screening_question)
    expect(current_path).to eq("/able_screening_questions/#{able_screening_question.id}/edit")
  end

  scenario 'login as manager' do
    login_as(manager)

    visit new_able_screens_question_submissions_able_screening_question_path
    expect(current_path).to eq('/able_screening_questions/new')

    visit edit_able_screens_question_submissions_able_screening_question_path(able_screening_question)
    expect(current_path).to eq("/able_screening_questions/#{able_screening_question.id}/edit")
  end

  scenario 'login as ec manager' do
    login_as(ec_manager)

    visit new_able_screens_question_submissions_able_screening_question_path
    expect(current_path).to eq('/users/sign_in')

    visit edit_able_screens_question_submissions_able_screening_question_path(able_screening_question)
    expect(current_path).to eq('/users/sign_in')
  end

  scenario 'login as fc manager' do
    login_as(fc_manager)

    visit new_able_screens_question_submissions_able_screening_question_path
    expect(current_path).to eq('/users/sign_in')

    visit edit_able_screens_question_submissions_able_screening_question_path(able_screening_question)
    expect(current_path).to eq('/users/sign_in')
  end

  scenario 'login as kc manager' do
    login_as(kc_manager)

    visit new_able_screens_question_submissions_able_screening_question_path
    expect(current_path).to eq('/users/sign_in')

    visit edit_able_screens_question_submissions_able_screening_question_path(able_screening_question)
    expect(current_path).to eq('/users/sign_in')
  end

  scenario 'login as able manager' do
    login_as(able_manager)

    visit new_able_screens_question_submissions_able_screening_question_path
    expect(current_path).to eq('/able_screening_questions/new')

    visit edit_able_screens_question_submissions_able_screening_question_path(able_screening_question)
    expect(current_path).to eq("/able_screening_questions/#{able_screening_question.id}/edit")
  end

  scenario 'login as case worker' do
    login_as(case_worker)

    visit new_able_screens_question_submissions_able_screening_question_path
    expect(current_path).to eq('/able_screening_questions/new')

    visit edit_able_screens_question_submissions_able_screening_question_path(able_screening_question)
    expect(current_path).to eq("/able_screening_questions/#{able_screening_question.id}/edit")
  end

  scenario 'login as strategic overviewer' do
    login_as(strategic_overviewer)

    visit new_able_screens_question_submissions_able_screening_question_path
    expect(current_path).to eq('/users/sign_in')

    visit edit_able_screens_question_submissions_able_screening_question_path(able_screening_question)
    expect(current_path).to eq('/users/sign_in')
  end
end

feature 'Family' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:able_manager){ create(:user, roles: 'able manager') }
  let!(:ec_manager){ create(:user, roles: 'ec manager') }
  let!(:fc_manager){ create(:user, roles: 'fc manager') }
  let!(:kc_manager){ create(:user, roles: 'kc manager') }
  let!(:manager){ create(:user, roles: 'manager') }
  let!(:stragic_overviewer){ create(:user, roles: 'strategic overviewer') }
  let!(:case_worker){ create(:user, roles: 'case worker') }

  let!(:family) { create(:family) }

  scenario 'login as admin' do
    login_as(admin)

    visit families_path
    expect(current_path).to eq('/families')

    visit new_family_path
    expect(current_path).to eq('/families/new')

    visit edit_family_path(family)
    expect(current_path).to eq("/families/#{family.id}/edit")

    visit family_path(family.id)
    expect(current_path).to eq("/families/#{family.id}")
  end

  scenario 'login as manager' do
    login_as(manager)

    visit families_path
    expect(current_path).to eq('/families')

    visit new_family_path
    expect(current_path).to eq('/families/new')

    visit edit_family_path(family)
    expect(current_path).to eq("/families/#{family.id}/edit")

    visit family_path(family.id)
    expect(current_path).to eq("/families/#{family.id}")
  end

  scenario 'login as ec manage' do
    login_as(ec_manager)

    visit families_path
    expect(current_path).to eq('/families')

    visit new_family_path
    expect(current_path).to eq('/families/new')

    visit edit_family_path(family)
    expect(current_path).to eq("/families/#{family.id}/edit")

    visit family_path(family.id)
    expect(current_path).to eq("/families/#{family.id}")

  end

  scenario 'login as fc manage' do
    login_as(fc_manager)

    visit families_path
    expect(current_path).to eq('/families')

    visit new_family_path
    expect(current_path).to eq('/families/new')

    visit edit_family_path(family)
    expect(current_path).to eq("/families/#{family.id}/edit")

    visit family_path(family.id)
    expect(current_path).to eq("/families/#{family.id}")
  end

  scenario 'login as kc manage' do
    login_as(kc_manager)

    visit families_path
    expect(current_path).to eq('/families')

    visit new_family_path
    expect(current_path).to eq('/families/new')

    visit edit_family_path(family)
    expect(current_path).to eq("/families/#{family.id}/edit")

    visit family_path(family.id)
    expect(current_path).to eq("/families/#{family.id}")
  end

  scenario 'login as able manager' do
    login_as(able_manager)

    visit families_path
    expect(current_path).to eq('/users/sign_in')

    visit new_family_path
    expect(current_path).to eq('/users/sign_in')

    visit edit_family_path(family)
    expect(current_path).to eq('/users/sign_in')

    visit family_path(family.id)
    expect(current_path).to eq('/users/sign_in')
  end

  scenario 'login as strategic overviewer' do
    login_as(stragic_overviewer)

    visit families_path
    expect(current_path).to eq('/families')

    visit new_family_path
    expect(current_path).to eq('/users/sign_in')

    visit edit_family_path(family)
    expect(current_path).to eq('/users/sign_in')

    visit family_version_path(family)
    expect(current_path).to eq("/families/#{family.id}/version")

    visit family_path(family.id)
    expect(current_path).to eq("/families/#{family.id}")
  end

  scenario 'login as case worker' do
    login_as(case_worker)

    visit families_path
    expect(current_path).to eq('/users/sign_in')

    visit new_family_path
    expect(current_path).to eq('/users/sign_in')

    visit edit_family_path(family)
    expect(current_path).to eq('/users/sign_in')

    visit family_path(family.id)
    expect(current_path).to eq('/users/sign_in')
  end
end

feature 'Client' do
  feature 'list' do
    feature 'login as' do
      let!(:admin){ create(:user, :admin) }
      let!(:manager_d){ create(:user, :manager, first_name: 'Manager D') }
      let!(:manager_a){ create(:user, :manager, first_name: 'Manager A', manager_id: manager_d.id) }
      let!(:manager_b){ create(:user, :manager, first_name: 'Manager B', manager_id: manager_d.id) }
      let!(:manager_c){ create(:user, :manager, first_name: 'Manager C', manager_id: manager_d.id) }

      let!(:case_worker_a){ create(:user, :case_worker, first_name: 'Case Worker A', manager_id: manager_a.id) }
      let!(:case_worker_b){ create(:user, :case_worker, first_name: 'Case Worker B', manager_id: manager_b.id) }
      let!(:case_worker_c){ create(:user, :case_worker, first_name: 'Case Worker C', manager_id: manager_c.id) }

      let!(:client_a){ create(:client, given_name: 'Child A', user_ids: [case_worker_a.id, case_worker_b.id]) }
      let!(:client_b){ create(:client, given_name: 'Child B', user_ids: [case_worker_b.id]) }
      let!(:client_c){ create(:client, given_name: 'Child C', user_ids: [case_worker_b.id, case_worker_c.id]) }

      feature 'Caseworker A' do
        before do
          login_as(case_worker_a)
          visit clients_path
        end

        it { expect(page).to have_content(client_a.given_name) }
        it { expect(page).not_to have_content(client_b.given_name) }
        it { expect(page).not_to have_content(client_c.given_name) }
      end

      feature 'Caseworker B' do
        before do
          login_as(case_worker_b)
          visit clients_path
        end

        it { expect(page).to have_content(client_a.given_name) }
        it { expect(page).to have_content(client_b.given_name) }
        it { expect(page).to have_content(client_c.given_name) }
      end

      feature 'Caseworker C' do
        before do
          login_as(case_worker_c)
          visit clients_path
        end

        it { expect(page).to have_content(client_c.given_name) }
        it { expect(page).not_to have_content(client_a.given_name) }
        it { expect(page).not_to have_content(client_b.given_name) }
      end

      feature 'Manager A' do
        before do
          login_as(manager_a)
          visit clients_path
        end

        it { expect(page).to have_content(client_a.given_name) }
        it { expect(page).not_to have_content(client_b.given_name) }
        it { expect(page).not_to have_content(client_c.given_name) }
      end

      feature 'Manager B' do
        before do
          login_as(manager_b)
          visit clients_path
        end

        it { expect(page).to have_content(client_c.given_name) }
        it { expect(page).to have_content(client_a.given_name) }
        it { expect(page).to have_content(client_b.given_name) }
      end

      feature 'Manager C' do
        before do
          login_as(manager_c)
          visit clients_path
        end

        it { expect(page).to have_content(client_c.given_name) }
        it { expect(page).not_to have_content(client_a.given_name) }
        it { expect(page).not_to have_content(client_b.given_name) }
      end

      feature 'Manager D' do
        before do
          login_as(manager_d)
          visit clients_path
        end

        it { expect(page).to have_content(client_c.given_name) }
        it { expect(page).to have_content(client_a.given_name) }
        it { expect(page).to have_content(client_b.given_name) }
      end

      feature 'Admin' do
        before do
          login_as(admin)
          visit clients_path
        end

        it { expect(page).to have_content(client_c.given_name) }
        it { expect(page).to have_content(client_a.given_name) }
        it { expect(page).to have_content(client_b.given_name) }
      end
    end
  end
end

feature 'progress_note' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:ec_manager){ create(:user, roles: 'ec manager') }
  let!(:fc_manager){ create(:user, roles: 'fc manager') }
  let!(:kc_manager){ create(:user, roles: 'kc manager') }
  let!(:ec_client){ create(:client, able_state: Client::ABLE_STATES[0], users: [ec_manager]) }
  let!(:fc_client){ create(:client, able_state: Client::ABLE_STATES[0], users: [fc_manager]) }
  let!(:kc_client){ create(:client, able_state: Client::ABLE_STATES[0], users: [kc_manager]) }
  let!(:fc_progress_note){ create(:progress_note, client: fc_client) }
  let!(:kc_progress_note){ create(:progress_note, client: kc_client) }

  feature 'link on Client detail page' do
    before do
      login_as(ec_manager)
      visit client_path(ec_client)
    end

    scenario 'is invisible logged in as EC Manager' do
      expect(page).not_to have_link('Progress Note', client_progress_notes_path(ec_client))
    end
  end

  feature 'List' do
    feature 'logged in as Admin' do
      before do
        login_as(admin)
        visit client_progress_notes_path(fc_progress_note.client)
      end
      scenario 'enabled add button' do
        expect(page).not_to have_css('.btn-add.disabled')
      end
      scenario 'enabled edit button' do
        expect(page).not_to have_css('.btn-edit.disabled')
      end
      scenario 'enabled delete button' do
        expect(page).not_to have_css('.btn-delete.disabled')
      end
    end

    feature 'logged in as FC Manager' do
      before do
        login_as(fc_manager)
        visit client_progress_notes_path(fc_progress_note.client)
      end
      scenario 'disabled add button' do
        expect(page).not_to have_css('.btn-add')
      end
      scenario 'disabled edit button' do
        expect(page).not_to have_css('.btn-edit')
      end
      scenario 'disabled delete button' do
        expect(page).not_to have_css('.btn-delete')
      end
    end

    feature 'logged in as KC Manager' do
      before do
        login_as(kc_manager)
        visit client_progress_notes_path(kc_progress_note.client)
      end
      scenario 'disabled add button' do
        expect(page).not_to have_css('.btn-add')
      end
      scenario 'disabled edit button' do
        expect(page).not_to have_css('.btn-edit')
      end
      scenario 'disabled delete button' do
        expect(page).not_to have_css('.btn-delete')
      end
    end
  end
end

