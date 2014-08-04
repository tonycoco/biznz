ActiveAdmin.register Contact do
  permit_params :id, :first_name, :last_name, :email, :title, :created_at, :updated_at
end
