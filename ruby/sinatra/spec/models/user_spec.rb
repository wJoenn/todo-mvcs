RSpec.describe User do
  let(:email) { "user@example.com" }
  let(:password) { "password" }

  describe "associations" do
    it "has many Task" do
      user = create(:user)
      create(:task, user:)

      expect(user.tasks).to all be_a Task
    end
  end

  describe "validations" do
    it "creates a new User with proper params" do
      user = described_class.create(email:, password:)
      expect(user).to be_persisted
    end

    it "validates the presence of the email" do
      user = described_class.create(password:)

      expect(user).not_to be_persisted
      expect(user.errors.full_messages).to contain_exactly "Email can't be blank"
    end

    it "validates the format of the email" do
      user = described_class.create(email: "wrong@example", password:)

      expect(user).not_to be_persisted
      expect(user.errors.full_messages).to contain_exactly "Email is invalid"
    end

    it "validates the uniqueness of the email" do
      described_class.create(email:, password:)
      user = described_class.create(email:, password:)

      expect(user).not_to be_persisted
      expect(user.errors.full_messages).to contain_exactly "Email has already been taken"
    end
  end
end
