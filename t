[1mdiff --git a/app/controllers/clients_controller.rb b/app/controllers/clients_controller.rb[m
[1mindex 3c7d46ca5..192487b06 100644[m
[1m--- a/app/controllers/clients_controller.rb[m
[1m+++ b/app/controllers/clients_controller.rb[m
[36m@@ -180,7 +180,7 @@[m [mclass ClientsController < AdminController[m
     end[m
     if deleted[m
       Task.with_deleted.where(client_id: @client.id).each(&:destroy_fully!)[m
[31m-      redirect_to clients_url, notice: t('.successfully_deleted')[m
[32m+[m[32m       redirect_to clients_url, notice: t('.successfully_deleted')[m
     else[m
       messages = @client.errors.full_messages.uniq.join('\n')[m
       redirect_to @client, alert: messages[m
[1mdiff --git a/app/helpers/clients_helper.rb b/app/helpers/clients_helper.rb[m
[1mindex 1720bf2c7..f62225f39 100644[m
[1m--- a/app/helpers/clients_helper.rb[m
[1m+++ b/app/helpers/clients_helper.rb[m
[36m@@ -1410,4 +1410,13 @@[m [mmodule ClientsHelper[m
     fields = %w(national_id passport birth_cert family_book travel_doc letter_from_immigration_police ngo_partner mosavy dosavy msdhs complain local_consent warrant verdict screening_interview_form short_form_of_ocdm short_form_of_mosavy_dosavy detail_form_of_mosavy_dosavy short_form_of_judicial_police police_interview other_legal_doc)[m
     FieldSetting.without_hidden_fields.where(name: fields).pluck(:name)[m
   end[m
[32m+[m
[32m+[m[32m  def if_date_of_birth_blank(client)[m
[32m+[m[32m    client.date_of_birth.blank? ? '#screening-tool-warning' : new_client_screening_assessment_path(client)[m
[32m+[m[32m  end[m
[32m+[m
[32m+[m[32m  def has_of_warning_model_if_dob_blank(client)[m
[32m+[m[32m    return { "data-target": "#screening-tool-warning", "data-toggle": "modal" } if client.date_of_birth.blank?[m
[32m+[m[32m    {}[m
[32m+[m[32m  end[m
 end[m
[1mdiff --git a/app/models/client.rb b/app/models/client.rb[m
[1mindex c5f59ba1d..99b704ac9 100644[m
[1m--- a/app/models/client.rb[m
[1m+++ b/app/models/client.rb[m
[36m@@ -326,7 +326,8 @@[m [mclass Client < ActiveRecord::Base[m
   def require_screening_assessment?(setting)[m
     setting.use_screening_assessment? &&[m
     referred? &&[m
[31m-    custom_fields.exclude?(setting.screening_assessment_form)[m
[32m+[m[32m    custom_fields.exclude?(setting.screening_assessment_form) &&[m
[32m+[m[32m    setting.screening_assessment_form.entity_type == "Client"[m
   end[m
 [m
   def self.age_between(min_age, max_age)[m
[36m@@ -713,6 +714,10 @@[m [mclass Client < ActiveRecord::Base[m
     result[m
   end[m
 [m
[32m+[m[32m  def one_off_screening_assessment[m
[32m+[m[32m    screening_assessments.find_by(screening_type: 'one_off')[m
[32m+[m[32m  end[m
[32m+[m
   private[m
 [m
   def update_related_family_member[m
[1mdiff --git a/app/models/screening_assessment.rb b/app/models/screening_assessment.rb[m
[1mindex 33c28f70c..3212e71c8 100644[m
[1m--- a/app/models/screening_assessment.rb[m
[1m+++ b/app/models/screening_assessment.rb[m
[36m@@ -1,6 +1,7 @@[m
 class ScreeningAssessment < ActiveRecord::Base[m
   belongs_to :client[m
 [m
[32m+[m[32m  enum screening_type: { one_off: 'one_off', multiple: 'multiple' }[m
   validates :screening_assessment_date, :visitor, :client_milestone_age, presence: :true[m
   validates :smile_back_during_interaction, :follow_object_passed_midline,[m
             :turn_head_to_sound, :head_up_45_degree, inclusion: { in: [true, false] }[m
[1mdiff --git a/app/views/clients/show.haml b/app/views/clients/show.haml[m
[1mindex e9777962c..81d5c5c9f 100644[m
[1m--- a/app/views/clients/show.haml[m
[1m+++ b/app/views/clients/show.haml[m
[36m@@ -63,9 +63,20 @@[m
                           %span.caret[m
                         %ul.dropdown-menu.btn-fit.scrollable-dropdown-menu.add-form[m
                           %li[m
[31m-                            %p= link_to 'CB-DMAT Screening Tool', '#screening-tool-warning', "data-target" => "#screening-tool-warning", "data-toggle" => "modal", type: "button"[m
[32m+[m[32m                            %p= link_to 'CB-DMAT Screening Tool', if_date_of_birth_blank(@client), type: "button", **has_of_warning_model_if_dob_blank(@client)[m
                           %li[m
                             %p= link_to t('.complete_screening_assessment'), new_client_custom_field_property_path(@client, custom_field_id: current_setting.screening_assessment_form)[m
[32m+[m[32m                    - elsif current_setting.cbdmat_one_off[m
[32m+[m[32m                      .btn-group.small-btn-margin[m
[32m+[m[32m                        %button.btn-sm.btn.btn-success.dropdown-toggle.btn-fit{ data: { toggle: "dropdown", trigger: 'hover', html: 'true', content: "#{I18n.t('inline_help.clients.show.add_form')}", placement: "auto" }, class: ('disabled' if @free_client_forms.empty? || (status_exited?(@client.status) && !current_user.admin?)) }[m
[32m+[m[32m                          = t('.complete_screening_tool')[m
[32m+[m[32m                          %span.caret[m
[32m+[m[32m                        %ul.dropdown-menu.btn-fit.scrollable-dropdown-menu.add-form[m
[32m+[m[32m                          %li[m
[32m+[m[32m                            - if @client.one_off_screening_assessment.present?[m
[32m+[m[32m                              %p= link_to 'CB-DMAT Screening Tool', client_screening_assessment_path(@client, @client.one_off_screening_assessment)[m
[32m+[m[32m                            - else[m
[32m+[m[32m                              %p= link_to 'CB-DMAT Screening Tool', if_date_of_birth_blank(@client), type: "button", **has_of_warning_model_if_dob_blank(@client)[m
                     - elsif @client.require_screening_assessment?(current_setting)[m
                       = link_to t('.complete_screening_assessment'), new_client_custom_field_property_path(@client, custom_field_id: current_setting.screening_assessment_form), class: 'btn btn-success'[m
                     - elsif @client.custom_fields.include?(current_setting.screening_assessment_form)[m
[1mdiff --git a/app/views/screening_assessments/show.html.haml b/app/views/screening_assessments/show.html.haml[m
[1mindex 0b183ecb1..297d0a1d9 100644[m
[1m--- a/app/views/screening_assessments/show.html.haml[m
[1m+++ b/app/views/screening_assessments/show.html.haml[m
[36m@@ -2,16 +2,16 @@[m
   .col-xs-12.col-sm-10.col-sm-offset-1[m
     .ibox#screening-assessment-info.center-block[m
       .ibox-title[m
[31m-        = link_to client_screening_assessments_path(@client), class: 'btn btn-default' do[m
[32m+[m[32m        = link_to client_path(@client), class: 'btn btn-default' do[m
           = fa_icon 'arrow-left'[m
[31m-          = t('.back_to_screening_assessments')[m
[32m+[m[32m          = t('.back_to_clients')[m
       .ibox-content[m
         .row[m
           .col-xs-10[m
             %p[m
[31m-              %b= "#{t('.client_name')} #{@screening_assessment.client.name}"[m
[31m-              - if @screening_assessment.index_of == 0[m
[31m-                = "#{t('.screening_assessment_one_off')}"[m
[32m+[m[32m              %b= "#{t('assessments.client_name')} #{@screening_assessment.client.name}"[m
[32m+[m[32m              - if @screening_assessment.one_off?[m
[32m+[m[32m                = t('.screening_assessment_one_off')[m
               - else[m
                 = "#{t('.based_on')} #{@screening_assessment.index_of + 1}"[m
               %br[m
[1mdiff --git a/db/schema.rb b/db/schema.rb[m
[1mindex 1b3e91527..072795aeb 100644[m
[1m--- a/db/schema.rb[m
[1m+++ b/db/schema.rb[m
[36m@@ -11,7 +11,7 @@[m
 #[m
 # It's strongly recommended that you check this file into your version control system.[m
 [m
[31m-ActiveRecord::Schema.define(version: 20220302025914) do[m
[32m+[m[32mActiveRecord::Schema.define(version: 20220303033525) do[m
 [m
   # These are extensions that must be enabled in order to support this database[m
   enable_extension "plpgsql"[m
[36m@@ -2106,10 +2106,12 @@[m [mActiveRecord::Schema.define(version: 20220302025914) do[m
     t.boolean  "turn_head_to_sound"[m
     t.boolean  "head_up_45_degree"[m
     t.integer  "client_id"[m
[32m+[m[32m    t.string   "screening_type"[m
   end[m
 [m
   add_index "screening_assessments", ["client_id"], name: "index_screening_assessments_on_client_id", using: :btree[m
   add_index "screening_assessments", ["screening_assessment_date"], name: "index_screening_assessments_on_screening_assessment_date", using: :btree[m
[32m+[m[32m  add_index "screening_assessments", ["screening_type"], name: "index_screening_assessments_on_screening_type", using: :btree[m
 [m
   create_table "service_deliveries", force: :cascade do |t|[m
     t.string   "name"[m
