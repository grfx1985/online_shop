class Contact < ActiveRecord::Base
	validates :title, :description, :email,  presence: true
end
