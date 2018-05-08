# describe 'Location' do
#   let!(:admin){ create(:user, roles: 'admin') }
#   let!(:location){ create(:location, name: 'ផ្សេងៗ Other', order_option: 1) }
#   let!(:used_location){ create(:location) }
#   let!(:new_location){ create(:location) }
#   let!(:progress_note){ create(:progress_note, location: used_location) }
#
#   before do
#     login_as(admin)
#   end
#
#   feature 'List' do
#     before do
#       FactoryGirl.create_list(:location, 20)
#       visit locations_path
#     end
#
#     scenario 'name' do
#       visit '/locations?page=2'
#       expect(page).to have_content(location.name)
#     end
#
#     scenario 'edit link' do
#       expect(page).to have_link(nil, edit_location_path(location))
#     end
#
#     scenario 'diable delete link' do
#       expect(page).not_to have_css("a[href='#{location_path(location)}'][data-method='delete']")
#     end
#
#     scenario 'new link' do
#       expect(page).to have_link('Add New Location', new_location_path)
#     end
#
#     scenario 'pagination' do
#       expect(page).to have_css('.pagination')
#     end
#   end
#
#   feature 'Create', js: true do
#     let!(:other_location) { create(:location, name: 'Other Location') }
#     before do
#       visit locations_path
#     end
#
#     scenario 'valid' do
#       click_link('Add New Location')
#       within('#new_location') do
#         fill_in 'Name', with: 'Location Name'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Location Name')
#     end
#
#     scenario 'invalid' do
#       click_link('Add New Location')
#       within('#new_location') do
#         fill_in 'Name', with: 'Other Location'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Other Location', count: 1)
#     end
#   end
#
#   feature 'Edit', js: true do
#     let!(:other_location) { create(:location, name: 'Home') }
#     before do
#       visit locations_path
#     end
#     scenario 'valid' do
#       find("a[data-target='#locationModal-#{other_location.id}']").click
#       within("#locationModal-#{other_location.id}") do
#         fill_in 'Name', with: 'Updated Name'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Updated Name')
#     end
#     scenario 'invalid' do
#       find("a[data-target='#locationModal-#{other_location.id}']").click
#       within("#locationModal-#{other_location.id}") do
#         fill_in 'Name', with: ''
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Home', count: 1)
#     end
#   end
#
#   feature 'Delete', js: true do
#     before do
#       visit locations_path
#     end
#     scenario 'success' do
#       find("a[href='#{location_path(new_location)}'][data-method='delete']").click
#       sleep 1
#       expect(page).not_to have_content(new_location.name)
#     end
#
#     scenario 'does not succeed' do
#       expect(page).to have_css("a[href='#{location_path(used_location)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
#     end
#   end
# end
