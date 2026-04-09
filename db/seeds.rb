# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

DEFAULT_PASSWORD = "ChangeMe123!"

USERS = [
	{ email: "superadmin@plannify.local", full_name: "Super Admin", role: "superadmin" },
	{ email: "admin@plannify.local", full_name: "Gym Admin", role: "admin" },
	{ email: "coach@plannify.local", full_name: "Coach Demo", role: "coach" },
	{ email: "client@plannify.local", full_name: "Client Demo", role: "client" }
].freeze

GYM_DATA = {
	name: "Plannify Main Gym",
	address: "Center City"
}.freeze

def upsert_user(email:, full_name:, role:, password: nil, gym: nil)
	user = User.find_or_initialize_by(email: email)
	attrs = {
		full_name: full_name,
		role: role,
		phone_number: "+21600000000",
		confirmed_at: Time.current
	}
	attrs[:gym] = gym if gym.present?
	attrs[:password] = password if password.present?
	attrs[:password_confirmation] = password if password.present?
	user.assign_attributes(attrs)
	user.save!
	user
end

superadmin = upsert_user(
	email: USERS[0][:email],
	full_name: USERS[0][:full_name],
	role: "superadmin",
	password: DEFAULT_PASSWORD
)

admin = upsert_user(
	email: USERS[1][:email],
	full_name: USERS[1][:full_name],
	role: "admin",
	password: DEFAULT_PASSWORD
)

gym = Gym.find_or_create_by!(name: GYM_DATA[:name]) do |g|
	g.address = GYM_DATA[:address]
	g.admin = admin
end

gym.update!(admin: admin) if gym.admin != admin

coach = upsert_user(
	email: USERS[2][:email],
	full_name: USERS[2][:full_name],
	role: "coach",
	gym: gym
)

client = upsert_user(
	email: USERS[3][:email],
	full_name: USERS[3][:full_name],
	role: "client",
	gym: gym
)

training_group = TrainingGroup.find_or_create_by!(name: "Morning Cardio", gym: gym) do |group|
	group.coach = coach
	group.capacity = 20
end

training_group.update!(coach: coach, capacity: 20)

session = PlanningSession.find_or_create_by!(
	training_group: training_group,
	start_time: Time.current.change(hour: 9, min: 0),
	end_time: Time.current.change(hour: 10, min: 0)
) do |planning|
	planning.recurrence = "weekly"
end

Attendance.find_or_create_by!(
	training_group: training_group,
	client: client,
	date: Date.current
) do |attendance|
	attendance.status = "present"
end

GroupMembership.find_or_create_by!(
	client: client,
	training_group: training_group
)

puts "Seed completed."
puts "Superadmin: #{superadmin.email} / #{DEFAULT_PASSWORD}"
puts "Admin: #{admin.email} / #{DEFAULT_PASSWORD}"
puts "Coach: #{coach.email} (no password)"
puts "Client: #{client.email} (no password)"
