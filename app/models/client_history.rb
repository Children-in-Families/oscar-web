class ClientHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  def self.initial(obj)
    create(object: obj.attributes)
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