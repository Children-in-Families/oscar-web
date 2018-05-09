# describe 'Intervention' do
#   let!(:admin){ create(:user, roles: 'admin') }
#   let!(:intervention){ create(:intervention, action: 'AAA') }
#
#   before do
#     login_as(admin)
#   end
#
#   feature 'List' do
#     before do
#       FactoryGirl.create_list(:intervention, 20)
#       visit interventions_path
#     end
#
#     scenario 'action' do
#       expect(page).to have_content(intervention.action)
#     end
#
#     scenario 'edit link' do
#       expect(page).to have_link(nil, edit_intervention_path(intervention))
#     end
#
#     scenario 'delete link' do
#       expect(page).to have_css("a[href='#{intervention_path(intervention)}'][data-method='delete']")
#     end
#
#     scenario 'new link' do
#       expect(page).to have_link('Add New Intervention', new_intervention_path)
#     end
#
#     scenario 'pagination' do
#       expect(page).to have_css('.pagination')
#     end
#   end
#
#   feature 'Create', js: true do
#     let!(:other_intervention) { create(:intervention, action: 'Other Intervention') }
#     before do
#       visit interventions_path
#     end
#
#     scenario 'valid' do
#       click_link('New Intervention')
#       within('#new_intervention') do
#         fill_in 'Action', with: 'New Intervention'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('New Intervention')
#     end
#
#     scenario 'invalid' do
#       click_link('New Intervention')
#       within('#new_intervention') do
#         fill_in 'Action', with: 'Other Intervention'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Other Intervention', count: 1)
#     end
#   end
#
#   feature 'Edit', js: true do
#     let!(:other_intervention) { create(:intervention, action: 'Counseling') }
#     before do
#       visit interventions_path
#     end
#     scenario 'valid' do
#       find("a[data-target='#interventionModal-#{intervention.id}']").click
#       within("#interventionModal-#{intervention.id}") do
#         fill_in 'Action', with: 'Updated Action'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Updated Action')
#     end
#     scenario 'invalid' do
#       find("a[data-target='#interventionModal-#{intervention.id}']").click
#       within("#interventionModal-#{intervention.id}") do
#         fill_in 'Action', with: 'Counseling'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Counseling', count: 1)
#     end
#   end
#
#   feature 'Delete', js: true do
#     before do
#       visit interventions_path
#     end
#     scenario 'success' do
#       find("a[href='#{intervention_path(intervention)}'][data-method='delete']").click
#       sleep 1
#       expect(page).not_to have_content(intervention.action)
#     end
#   end
# end
