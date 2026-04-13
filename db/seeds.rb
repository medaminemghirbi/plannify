# frozen_string_literal: true

puts "🌱 Seeding..."

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

# =========================
# HELPERS
# =========================

def create_user_if_missing(email:, full_name:, role:, password: nil, gym: nil)
  user = User.find_by(email: email)
  return user if user.present?

  User.create!(
    email: email,
    full_name: full_name,
    role: role,
    phone_number: "+21600000000",
    confirmed_at: Time.current,
    gym: gym,
    password: password,
    password_confirmation: password
  )
end

# =========================
# USERS
# =========================

superadmin = create_user_if_missing(
  email: USERS[0][:email],
  full_name: USERS[0][:full_name],
  role: "superadmin",
  password: DEFAULT_PASSWORD
)

admin = create_user_if_missing(
  email: USERS[1][:email],
  full_name: USERS[1][:full_name],
  role: "admin",
  password: DEFAULT_PASSWORD
)

# =========================
# GYM
# =========================

gym = Gym.find_by(name: GYM_DATA[:name])

if gym.nil?
  gym = Gym.create!(
    name: GYM_DATA[:name],
    address: GYM_DATA[:address],
    admin: admin
  )
else
  # only assign if admin not already linked elsewhere
  unless Gym.exists?(admin: admin)
    gym.update!(admin: admin)
  end
end
# =========================
# OTHER USERS (depend on gym)
# =========================

coach = create_user_if_missing(
  email: USERS[2][:email],
  full_name: USERS[2][:full_name],
  role: "coach",
  gym: gym
)

client = create_user_if_missing(
  email: USERS[3][:email],
  full_name: USERS[3][:full_name],
  role: "client",
  gym: gym
)

# =========================
# TRAINING GROUP
# =========================

training_group = TrainingGroup.find_by(
  name: "Morning Cardio",
  gym: gym
)

if training_group.nil?
  training_group = TrainingGroup.create!(
    name: "Morning Cardio",
    gym: gym,
    coach: coach,
    capacity: 20
  )
end

# =========================
# SESSION
# =========================

session = PlanningSession.find_by(
  training_group: training_group,
  start_time: Time.current.change(hour: 9, min: 0),
  end_time: Time.current.change(hour: 10, min: 0)
)

if session.nil?
  PlanningSession.create!(
    training_group: training_group,
    start_time: Time.current.change(hour: 9, min: 0),
    end_time: Time.current.change(hour: 10, min: 0),
    recurrence: "weekly"
  )
end

# =========================
# ATTENDANCE
# =========================

attendance = Attendance.find_by(
  training_group: training_group,
  client: client,
  date: Date.current
)

if attendance.nil?
  Attendance.create!(
    training_group: training_group,
    client: client,
    date: Date.current,
    status: "present"
  )
end

# =========================
# MEMBERSHIP
# =========================

membership = GroupMembership.find_by(
  client: client,
  training_group: training_group
)

if membership.nil?
  GroupMembership.create!(
    client: client,
    training_group: training_group
  )
end

# =========================
# DONE
# =========================

puts "✅ Seed completed (safe mode)."
puts "Superadmin: #{superadmin.email} / #{DEFAULT_PASSWORD}"
puts "Admin: #{admin.email} / #{DEFAULT_PASSWORD}"
puts "Coach: #{coach.email}"
puts "Client: #{client.email}"