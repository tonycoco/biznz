class Contact < ActiveRecord::Base
  validates :email, uniqueness: true
  validates :first_name, :last_name, :email, :title, presence: true
end
