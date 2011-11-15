class LocationMongoid
  include Mongoid::Document

  field :label, type: String # general text label
  field :location, type: Array # :lat, :long
  field :last_location, type: Array # :lat, :long


  index [[ :location, Mongo::GEO2D ]], min: -180, max: 180

end