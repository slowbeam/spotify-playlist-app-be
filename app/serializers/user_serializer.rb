class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :display_name, :profile_image, :sadlist_uri, :contentlist_uri, :ecstaticlist_uri
end
