# Client ask to hide #147254199

# describe "government_report" do
#   let!(:user) { create(:user) }
#   let!(:client) { create(:client, state: 'accepted', user: user) }
#
#   before do
#     login_as(user)
#   end
#
#   feature 'Create' do
#     before do
#       visit new_client_government_report_path(client)
#     end
#
#     scenario 'valid', js: true do
#       fill_in I18n.t('government_reports.form.code'), with: FFaker::Lorem.words.first
#       click_button I18n.t('.save')
#       sleep 1
#       expect(page).to have_content(I18n.t('government_reports.create.successfully_created'))
#     end
#
#     scenario  'invalid', js: true do
#       click_button I18n.t('.save')
#       expect(page).to have_content(I18n.t('activerecord.errors.models.government_report.attributes.code.blank'))
#       sleep 1
#       expect(page).not_to have_content(I18n.t('.successfully_created'))
#     end
#   end
#
#   feature 'List' do
#     let!(:government_report) { create(:government_report, code: FFaker::Lorem.words, client: client) }
#
#     before do
#       visit client_government_reports_path(client)
#     end
#
#     scenario 'form code' do
#       form_code = government_report.code
#       expect(page).to have_content(form_code)
#     end
#
#     scenario 'edit link' do
#       expect(page).to have_link(nil, href: edit_client_government_report_path(client, government_report))
#     end
#
#     scenario 'delete link' do
#       expect(page).to have_css("a[href='#{client_government_report_path(client, government_report)}'][data-method='delete']")
#     end
#
#     scenario 'view link' do
#       expect(page).to have_link(nil, href: client_government_report_path(client, government_report, format: :pdf))
#     end
#
#     scenario 'new link' do
#       expect(page).to have_link('Add Government Report', href: new_client_government_report_path(client))
#     end
#   end
# end
