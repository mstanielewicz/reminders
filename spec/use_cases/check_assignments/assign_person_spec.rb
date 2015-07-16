require "spec_helper"

describe CheckAssignments::AssignPerson do
  let(:service) do
    described_class.new(
      project_check: project_check,
      assignments_repo: assignments_repo,
      users_repo: users_repo,
    )
  end
  let(:project_check) do
    double(:project_check,
           id: 2,
           reminder: reminder,
           project: project,
          )
  end
  let(:users_repo) do
    repo = InMemoryRepository.new
    repo.all = [last_checker, user]
    repo
  end
  let(:assignments_repo) do
    class InMemoryAssignmentsRepository < InMemoryRepository
      def add(parameters)
        create(CheckAssignment.new(parameters))
      end
    end
    InMemoryAssignmentsRepository.new
  end
  let(:reminder) { double(:reminder, name: "sample review") }
  let(:project) { double(:project, name: "test", channel_name: "test") }
  let(:last_checker) { double(:user, name: "Jane Doe", id: 5) }
  let(:user) { double(:user, name: "John Doe", id: 4) }
  let(:info) do
    { person: user.name,
      reminder: reminder.name,
      project: project.name,
    }
  end

  describe "#assign" do
    it "creates new uncompleted check assignment" do
      expect { service.assign(last_checker) }
        .to change { assignments_repo.all.count }
        .by(1)
      expect(assignments_repo.all.first.completion_date).to eq nil
    end

    it "doesn't assign user that performed last check" do
      service.assign(last_checker)
      expect(assignments_repo.all.first.user_id).to eq user.id
    end

    it "attempts to send Slack notification" do
      expect_any_instance_of(CheckAssignments::Notify)
        .to receive(:notify)
        .with(project.channel_name, info)
      service.assign(last_checker)
    end

    it "returns notice text" do
      expect(service.assign(last_checker)).to be_an_instance_of String
    end
  end
end
