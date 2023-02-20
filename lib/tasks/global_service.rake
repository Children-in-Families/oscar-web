namespace :global_service do
  desc "Drop Global Service foreign key constrain."
  task :drop_constrain, [:short_name] => :environment do |task, args|
    service_data_file = Rails.root.join('lib/devdata/services/service.xlsx')
    if args.short_name
      Apartment::Tenant.switch args.short_name
      ActiveRecord::Base.connection.execute("ALTER TABLE #{args.short_name}.global_services DROP CONSTRAINT IF EXISTS fk_rails_dd8845518e")
      ActiveRecord::Base.connection.execute("ALTER TABLE #{args.short_name}.services DROP CONSTRAINT IF EXISTS fk_rails_dd8845518e;")
      ImportStaticService::DateService.new('Services', args.short_name, service_data_file).import
      update_services_uuid unless Service.count.zero?
    else
      Organization.without_shared.each do |org|
        Apartment::Tenant.switch org.short_name
        puts "=====================dropping contrain on schema #{org.short_name} ====================================="
        ActiveRecord::Base.connection.execute("ALTER TABLE #{org.short_name}.global_services DROP CONSTRAINT IF EXISTS fk_rails_dd8845518e;")
        ActiveRecord::Base.connection.execute("ALTER TABLE #{org.short_name}.services DROP CONSTRAINT IF EXISTS fk_rails_dd8845518e;")
        ImportStaticService::DateService.new('Services', org.short_name, service_data_file).import

        update_services_uuid
      end
    end
  end
end

def update_services_uuid
  services = Service.order(:uuid)
  services.each do |service|
    next if service.uuid == mapping_service_hash[service.name]

    service.uuid = mapping_service_hash[service.name]
    service.save
  end
end

def mapping_service_hash
  {
    "Social Work / Case Work"=>"01ad068b-fbe1-4ba4-955b-701c39064ad1",
    "Generalist social work / case work"=>"042ffb1c-51de-404b-b69b-fdb9e15c9d36",
    "Community social work"=>"0568a6f3-68a5-4fff-91c4-aafe4cd606ba",
    "Family Based Care"=>"070bc9bd-6b71-4dcb-8dc8-a27c39c4ade3",
    "Emergency foster care"=>"155c6b46-ac10-4226-b9fd-6e117111b08c",
    "Long term foster care"=>"1843eb37-7ec8-4131-8fb9-857559ac379b",
    "Kinship care"=>"1a1accbd-90a9-4c71-a077-2595322744cb",
    "Domestic adoption support"=>"1bd9f758-b332-4711-90df-67cf2da5fbef",
    "Family preservation"=>"1f9219fd-39fb-4f78-be49-6d49e65e3a82",
    "Family reunification"=>"2292c429-1384-4f47-a5aa-dace6a7425fd",
    "Independent Living"=>"2332dd46-0dd6-4de5-8dc4-9a231b3de9d4",
    "Drug/Alcohol"=>"23b00ad0-02b9-42c0-9fea-cc8e90a4385b",
    "Drug and Alcohol Counselling"=>"2ce1dfad-250f-4b97-b297-cf93971c5199",
    "Detox / rehabilitation services"=>"2eda5b5e-713a-4d8b-aba3-fc6677101583",
    "Detox support"=>"3084b947-db6c-49fd-b99b-aab64bc01e11",
    "Counselling"=>"30e4d990-a93c-4f5f-bf49-95d263e923f5",
    "Generalist counselling"=>"318d3ae6-979d-47e7-9d94-2bb978102078",
    "Counselling for abuse survivors"=>"31d3e688-3114-4c3b-9c7d-5108617ba045",
    "Trauma counselling"=>"37cd9808-c417-4a19-9563-36ac7865e2f8",
    "Family counselling / mediation"=>"3a3934a1-4e1f-4376-88f0-74aba189b616",
    "Financial Development"=>"3bd845fd-5e43-43fb-a7c2-9681535b2777",
    "Direct material assistance"=>"3c36d45b-bf1a-4988-80b8-767183082d45",
    "Direct financial assistance"=>"4d1df9a8-1e90-40e3-b978-93d283a4a48d",
    "Income generation services"=>"583dea6d-c0e0-40d5-ba1f-ce4bf7ec1d43",
    "Day care services"=>"5935484c-22bf-42b3-b86f-826ae7decccc",
    "Disability Support"=>"593b1bde-eb5f-474e-af4e-8acaee656888",
    "Therapeutic interventions"=>"9a3b4c0e-c2bb-4ca6-bbf2-23b7ae933af4",
    "Disability respite care"=>"5fe1565f-b152-478e-952d-40ca8ed81a94",
    "Therapeutic training"=>"9ea024e4-9a6b-4e6e-a0d6-e65758ef5462",
    "Disability-aid provision"=>"6a57e90a-80a1-49ee-abe9-b429b56c1591",
    "Peripheral supports"=>"6bd0d621-4a17-40dd-92c4-249270e44819",
    "Support groups"=>"71dc3014-9ff6-4fa2-9da8-ad9fe75be051",
    "Medical Support"=>"763c430d-fc92-4755-87f5-dde8ff6076ee",
    "Support to access care"=>"7b97ef20-4c25-4d83-b2cb-60efc1ba300f",
    "Provision of medical care"=>"7c3fd50a-4ec0-45df-b359-d584cbd587af",
    "Medical training services"=>"7cf865ff-04df-42d1-b56c-0454869a8c5d",
    "Health education"=>"7dff4d85-3c89-4bcd-8130-25733419f46a",
    "Legal Support"=>"835dfb2d-2f17-45a1-96d3-8bdc304dc8ad",
    "Support to access legal services"=>"86659a7b-52d4-4208-b73d-2ddf4d6dd5cd",
    "Legal advocacy services"=>"8a601af1-b738-4ed8-b47e-fcd079c00b33",
    "Legal representation"=>"8f12963c-7b3a-4161-b40c-5ee2bbfd587b",
    "Prison visitation support"=>"920868cf-4586-47dd-8536-5c1159b950f1",
    "Mental Health Support"=>"922c33c9-25c4-4fdc-b32e-24e929eaac37",
    "Direct medical support"=>"a06ff170-2452-49b6-b357-257b9b741a4c",
    "Training and Education"=>"a3045453-e5a1-4a89-b442-443c062a4e63",
    "School support"=>"a5647de9-4849-4106-a85c-6dbc0ac0ba50",
    "Supplementary school education"=>"ac096f81-c062-4553-b933-8d0619d6afd6",
    "Vocational education and training"=>"af088c36-d75f-4d8f-bc75-98d705faf625",
    "Material support for education (uniforms, etc)"=>
      "af99e68e-872b-4a6f-a6fc-785e1ba76db3",
    "Scholarships or financial support"=>"b3109dcc-cd03-44cd-b6cf-811dcfc246ff",
    "Life skills"=>"c7db1f28-8235-409c-acfd-51b0a1d546c8",
    "Family Support"=>"c9eb9132-b742-420a-8be5-dba9bfdbf4de",
    "Family support"=>"cb5bea66-c7eb-49ca-8fa7-a7d0ef0c889f",
    "Anti-Trafficking"=>"cbfd99bc-41bc-4686-be60-8cc70d6430c2",
    "Rescue Services"=>"cd738c25-49ea-4089-8267-8b56cac6da86",
    "Transitional Accommodation"=>"cee0935f-e7c2-4905-9a97-dd98a740c527",
    "Post-Trafficking Counseling"=>"d3df3fdb-1db2-463d-ae12-e43ee3e759fb",
    "Community Reintegration Support"=>"defe205c-5f8c-42ba-b3f9-4d905b856b2f",
    "Other"=>"efc03a88-165f-412a-ba3a-ff6211c5a9ce",
    "Residential Care Institution"=>"eff810d3-f1ff-4c79-976c-c3fcf5d4e392",
    "Other Service"=>"f1a4e827-19f7-4f96-90f6-69e35f73d867",
    "Not Specified"=>"f1a4e827-19f7-4f96-90f6-69e35f73d867",
    "Literacy Support"=>"f1d4c696-1de7-466e-8319-577a74bcc481"
  }
end
