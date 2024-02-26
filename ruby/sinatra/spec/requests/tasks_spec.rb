require_relative "../sinatra_helper"

RSpec.describe "/tasks", type: :request do
  describe "GET /tasks" do
    before do
      Task.create(title: "My task")
      get "/tasks"
    end

    it "returns a JSON array" do
      expect(last_response.body).to be_a String
      expect(JSON.parse(last_response.body)).to all have_key "id"
    end

    it "returns a list of Task" do
      data = JSON.parse(last_response.body)
      expect(data).to contain_exactly hash_including("title" => "My task", "completed" => false)
    end

    it "returns a HTTP status of success" do
      expect(last_response.status).to be 200
    end
  end

  describe "POST /tasks" do
    context "with proper param" do
      before do
        post "/tasks", params: { task: { title: "My task" } }
      end

      it "returns a JSON object" do
        expect(last_response.body).to be_a String
        expect(JSON.parse(last_response.body)).to have_key "id"
      end

      it "creates an instance of Task" do
        expect(Task.count).to eq 1
      end

      it "returns the new instance of Task" do
        data = JSON.parse(last_response.body)
        expect(data["title"]).to eq "My task"
      end

      it "returns a HTTP status of created" do
        expect(last_response.status).to be 202
      end
    end

    context "without proper params" do
      before do
        post "/tasks", params: { task: { title: nil } }
      end

      it "returns a JSON object" do
        expect(last_response.body).to be_a String
        expect(JSON.parse(last_response.body)).to have_key "errors"
      end

      it "does not create an instance of Task" do
        expect(Task.count).to eq 0
      end

      it "returns a list of error messages" do
        data = JSON.parse(last_response.body)
        expect(data["errors"]).to contain_exactly "Title can't be blank"
      end

      it "returns a HTTP status of unprocessable_entity" do
        expect(last_response.status).to be 404
      end
    end
  end

  describe "DELETE /tasks/:id" do
    before do
      task = Task.create(title: "My task")
      delete "/tasks/#{task.id}"
    end

    it "destroys the instance of Task" do
      expect(Task.count).to be 0
    end

    it "returns a HTTP status of success" do
      expect(last_response.status).to be 200
    end
  end

  describe "GET /tasks/:id/complete" do
    let!(:task) { Task.create(title: "My task") }

    before do
      patch "/tasks/#{task.id}/complete"
    end

    it "returns a JSON object" do
      expect(last_response.body).to be_a String
      expect(JSON.parse(last_response.body)).to have_key "id"
    end

    it "returns the updated instance of Task" do
      data = JSON.parse(last_response.body)
      expect(data["id"]).to be task.id
    end

    it "marks the Task instance as completed" do
      expect(Task.find(task.id)).to be_completed
    end

    it "returns a HTTP status of success" do
      expect(last_response.status).to be 200
    end
  end
end