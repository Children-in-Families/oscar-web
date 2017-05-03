# feature 'ClientAdvancedSearch' do
#   given(:admin) { create(:user, roles: 'admin') }
#
#   background do
#     login_as(admin)
#     visit clients_path
#   end
#
#   scenario 'Advanced search link' do
#     expect(page).to have_content 'Advanced Search'
#   end
#
#   scenario 'Advanced Search Text Field', js: true do
#     click_link 'Advanced Search'
#     wait_for_ajax
#     within '#builder_rule_0' do
#       select2_select('Given Name (Local)', '.rule-filter-container .select2-container')
#       expect(page).to have_content 'Given Name (Local)'
#       expect(page).to have_content 'is'
#     end
#   end
#
#   scenario 'Advanced Search Number Field', js: true do
#     click_link 'Advanced Search'
#     wait_for_ajax
#     within '#builder_rule_0' do
#       select2_select('Code', '.rule-filter-container .select2-container')
#       expect(page).to have_content 'Code'
#       expect(page).to have_content 'is'
#     end
#   end
#
#   scenario 'Advanced Search Drop list Field', js: true do
#     click_link 'Advanced Search'
#     wait_for_ajax
#     within '#builder_rule_0' do
#       select2_select('Gender', '.rule-filter-container .select2-container')
#       expect(page).to have_content 'Gender'
#       expect(page).to have_content 'is'
#       expect(page).to have_content 'Female'
#     end
#   end
#
#   scenario 'Advanced Search Datepicker Field', js: true do
#     click_link 'Advanced Search'
#     wait_for_ajax
#     within '#builder_rule_0' do
#       select2_select('Placement Start Date', '.rule-filter-container .select2-container')
#       expect(page).to have_content 'Placement Start Date'
#       expect(page).to have_content 'is'
#     end
#   end
#
# end
