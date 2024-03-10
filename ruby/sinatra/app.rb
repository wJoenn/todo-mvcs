require "sinatra"
require_relative "config/application"

helpers do
  def authenticate_user!
    jwt = env["HTTP_AUTHORIZATION"]
    @current_user = User.by_jwt(jwt)

    halt status 401 if @current_user.nil?
  end

  def parsed_params(resource_name, required_params)
    data = request.body.read
    parsed_params = data.present? ? JSON.parse(data) : params["params"]
    symbolized_params = JSON.parse(parsed_params.to_json, symbolize_names: true)

    symbolized_params&.[](resource_name)&.slice(*required_params) || {}
  end
end

get "/current_user" do
  authenticate_user!

  status 200
  @current_user.to_json
end

get "/tasks" do
  authenticate_user!

  status 200
  @current_user.tasks.to_json
end

post "/tasks" do
  authenticate_user!

  task_params = parsed_params(:task, %i[title])
  task = @current_user.tasks.new(task_params)

  if task.save
    status 201
    task.to_json
  else
    status 422
    { errors: task.errors.full_messages }.to_json
  end
end

delete "/tasks/:id" do
  authenticate_user!

  task = @current_user.tasks.find(params["id"])
  task.destroy

  status 200
end

patch "/tasks/:id/complete" do
  authenticate_user!

  task = @current_user.tasks.find(params["id"])
  task.update(completed: true)

  status 200
  task.to_json
end

post "/users" do
  user_params = parsed_params(:user, %i[email password password_confirmation])
  user = User.new(user_params)

  if user.save
    status 201
    response.headers["Authorization"] = user.jwt
    user.to_json
  else
    status 422
    { errors: user.errors.full_messages }.to_json
  end
end

post "/users/sign_in" do
  user_params = parsed_params(:user, %i[email password])
  user = User.find_by(email: user_params[:email])

  if user.present? && user.password == user_params[:password]
    status 200
    response.headers["Authorization"] = user.jwt
    user.to_json
  else
    status 401
    { errors: ["Invalid Email or Password"] }.to_json
  end
end

delete "/users/sign_out" do
  authenticate_user!

  @current_user.edit_jti
  @current_user.save

  status 200
end

options "*" do
  200
end

set :port, 3000
