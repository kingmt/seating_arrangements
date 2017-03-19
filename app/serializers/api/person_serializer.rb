class Api::PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :age, :seated, :seated_at_table
end
