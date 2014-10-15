json.array!(@contacts) do |contact|
  json.extract! contact, :id, :title, :description, :email
  json.url contact_url(contact, format: :json)
end
