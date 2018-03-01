# describe 'Province' do
#   let!(:admin){ create(:user, roles: 'admin') }
#   let!(:province){ create(:province) }
#   let!(:other_province){ create(:province) }
#   let!(:case){ create(:case, province: other_province) }
#   before do
#     login_as(admin)
#   end
#   feature 'List' do
#     before do
#       visit provinces_path
#     end
#     scenario 'name' do
#       expect(page).to have_content(province.name)
#     end
#     scenario 'edit link' do
#       expect(page).to have_css("i[class='fa fa-pencil']")
#     end
#     scenario 'delete link' do
#       expect(page).to have_css("a[href='#{province_path(province)}'][data-method='delete']")
#     end
#   end
#
#   feature 'Create', js: true do
#     let!(:other_province) { create(:province, name: 'SR') }
#     before do
#       visit provinces_path
#     end
#     scenario 'valid' do
#       click_link('Add New Province')
#       within('#new_province') do
#         fill_in 'Name', with: 'Phnom Penh'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('Phnom Penh')
#     end
#     scenario 'invalid' do
#       click_link('Add New Province')
#       within('#new_province') do
#         fill_in 'Name', with: 'SR'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('SR', count: 1)
#     end
#   end
#
#   feature 'Edit', js: true do
#     before do
#       visit provinces_path
#     end
#     scenario 'valid' do
#       find("a[data-target='#provinceModal-#{province.id}']").click
#       within("#provinceModal-#{province.id}") do
#         fill_in 'Name', with: 'TK'
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content('TK')
#     end
#     scenario 'invalid' do
#       find("a[data-target='#provinceModal-#{province.id}']").click
#       within("#provinceModal-#{province.id}") do
#         fill_in 'Name', with: ''
#         click_button 'Save'
#       end
#       sleep 1
#       expect(page).to have_content(province.name)
#     end
#   end
#
#   feature 'Delete', js: true do
#     before do
#       visit provinces_path
#     end
#     scenario 'success' do
#       find("a[href='#{province_path(province)}'][data-method='delete']").click
#       sleep 1
#       expect(page).not_to have_content(province.name)
#     end
#     scenario 'disable delete' do
#       expect(page).to have_css("a[href='#{province_path(other_province)}'][data-method='delete'][class='btn btn-outline btn-danger btn-xs disabled']")
#     end
#   end
# end
