class CallSerializer < ActiveModel::Serializer
  attributes :phone_call_id, :receiving_staff_id, :start_datetime, :end_datetime, :call_type 
end
