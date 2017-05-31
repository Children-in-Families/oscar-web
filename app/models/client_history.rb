class ClientHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  embeds_many :agency_client_histories
  embeds_many :client_family_histories
  embeds_many :case_client_histories

  after_save :create_agency_client_history, if: 'object.key?("agency_ids")'
  after_save :create_case_client_history,   if: 'object.key?("case_ids")'
  after_save :create_client_family_history, if: 'object.key?("family_ids")'

  def self.initial(client)
    attributes = client.attributes
    attributes = attributes.merge('agency_ids' => client.agency_ids) if client.agency_ids.any?
    attributes = attributes.merge('case_ids' => client.case_ids) if client.case_ids.any?
    attributes = attributes.merge('family_ids' => client.family_ids) if client.family_ids.any?
    create(object: attributes)
  end

  private

  def create_agency_client_history
    object['agency_ids'].each do |agency_id|
      agency = Agency.find_by(id: agency_id).try(:attributes)
      agency_client_histories.create(object: agency)
    end
  end

  def create_case_client_history
    object['case_ids'].each do |case_id|
      c_case = Case.find_by(id: case_id).try(:attributes)
      case_client_histories.create(object: c_case)
    end
  end

  def create_client_family_history
    object['family_ids'].each do |family_id|
      family = Family.find_by(id: family_id).try(:attributes)
      client_family_histories.create(object: family)
    end
  end
end

# To anser the questions:
  
  # 1. How many kids were placed in Emergency Care between 01/07/2015 and 30/06/2016?
    # I think this already exists in Basic Rules filter, Referred to EC/FC/KC, in this case EC
  
  # 2. How many active placements did we have in Kandal province in the first three months of 2017
    # Find clients with status Active EC or FC or KC and current_province is Kandal with Jan - Mar 2017

    # ClientHistory.where(id: '5926a415a27abe158dc385b7').where({'$or' => [{'object.status' => 'Active EC'}, {'object.status' => 'Active FC'}]}).count

    # s    = 'Sun, 01 Jan 2017'
    # e    = 'Fri, 31 Mar 2017'
    # p_id = Province.find_by(name: 'Kandal').try(:id)
    # ClientHistory.where(created_at: s..e, 'object.province_id' => p_id).where({'$or' => [{'object.status' => 'Active EC'}, {'object.status' => 'Active FC'}, { ... other or clause ... }]})
  
  # 3. Where did child X live in 2014? I think just to find child X
    # s = Date.today.beginning_of_year  
    # e = Date.today.end_of_year
    # ClientHistory.where('object.given_name' => 'X', created_at: s..e)
  
  # 4. Search to show all clients who have ever been referred to KC between April 1 2017 and April 24 2017
    # I think this already exists in Basic Rules filter, Referred to EC/FC/KC, in this case KC
