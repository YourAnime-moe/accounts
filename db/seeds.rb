# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Connext::Application.create!(
  name: 'Misete.io',
  uuid: Rails.application.credentials.connext[:naka][:uuid],
  secret: Rails.application.credentials.connext[:naka][:secret],
  redirect_uri: Rails.configuration.x.hosts[:naka_redirect_uri],
)

Doorkeeper::Application.create!(
  name: '[System] Misete.io',
  uid: Rails.application.credentials.connext[:naka][:uuid],
  secret: Rails.application.credentials.connext[:naka][:secret],
  redirect_uri: Rails.configuration.x.hosts[:naka_redirect_uri] + '/auth/misete/callback',
  scopes: 'read write email',
)

RegularUser.create!(
  first_name: 'Developer',
  last_name: 'User',
  email: 'dev@misete.io',
  password: 'password',
  username: 'dev',
  active: true,
)

AdminUser.create!(
  first_name: 'Admin',
  last_name: 'User',
  email: 'admin@misete.io',
  password: 'password',
  username: 'admin',
  active: true,
)
