# describe 'Material' do
#   let!(:admin){ create(:user, roles: 'admin') }
#   let!(:material){ create(:material, status: 'AAA') }
#   let!(:used_material){ create(:material) }
#   let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
#   let!(:progress_note){ create(:progress_note, material: used_material, location: location) }
#
#   before do
#     login_as(admin)
#   end
#
#   feature 'List' do
#     before do
#       FactoryGirl.create_list(:material, 20)
#       visit materials_path
#     end
#
#     scenario 'status' do
#       expect(page).to have_content(material.status)
#     end
#
#     scenario 'edit link' do
#       expect(page).to have_link(nil, edit_material_path(material))
#     end
#
#     scenario 'delete link' do
#       expect(page).to have_css("a[href='#{material_path(material)}'][data-method='delete']")
#     end
#
#     scenario 'new link' do
#       expect(page).to have_link('Add New Equipment/Material', new_material_path)
#     end
#
#     scenario 'pagination' do
#       expect(page).to have_css('.pagination')
#     end
#   end
#
#   feature 'Create', js: true do
#     let!(:other_material) { create(:material, status: 'Other Material') }
#     before do
#       visit materials_path
#     end
#
#     scenario 'valid' do
#       click_link('Add New Equipment/Material')
#       within('#new_material') do
#         fill_in 'Status', with: 'Good Quality'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Good Quality')
#     end
#
#     scenario 'invalid' do
#       click_link('Add New Equipment/Material')
#       within('#new_material') do
#         fill_in 'Status', with: 'Other Material'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Other Material', count: 1)
#     end
#   end
#
#   feature 'Edit', js: true do
#     let!(:other_material) { create(:material, status: 'Loan') }
#     before do
#       visit materials_path
#     end
#     scenario 'valid' do
#       find("a[data-target='#materialModal-#{other_material.id}']").click
#       within("#materialModal-#{other_material.id}") do
#         fill_in 'Status', with: 'Updated Status'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Updated Status')
#     end
#     scenario 'invalid' do
#       find("a[data-target='#materialModal-#{other_material.id}']").click
#       within("#materialModal-#{other_material.id}") do
#         fill_in 'Status', with: 'Loan'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Loan', count: 1)
#     end
#   end
#
#   feature 'Delete', js: true do
#     before do
#       visit materials_path
#     end
#     scenario 'success' do
#       find("a[href='#{material_path(material)}'][data-method='delete']").click
#       sleep 1
#       expect(page).not_to have_content(material.status)
#     end
#
#     scenario 'does not succeed' do
#       expect(page).to have_css("a[href='#{material_path(used_material)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
#     end
#   end
# end
