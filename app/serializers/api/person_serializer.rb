class Api::PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :age
end
