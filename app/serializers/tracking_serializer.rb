class TrackingSerializer < ActiveModel::Serializer
  attributes :id, :name, :fields, :frequency, :time_of_frequency, :program_stream_id, :hidden
end
