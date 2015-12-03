require "rails_helper"

describe CheckAssignments::SetDeadline do
  let(:assignment) { create(:check_assignment, user: create(:user)) }
  let(:assignments_repository) { CheckAssignmentsRepository.new }
  let(:service) do
    described_class.new(assignment: assignment,
                        assignments_repository: assignments_repository,
                        deadline: "2016-01-01",
                       )
  end

  describe "#call" do
    context "with valid params" do
      it "returns successful response" do
        expect(service.call).to be_kind_of(Response::Success)
      end

      it "changes assignment's deadline" do
        service.call
        expect(assignment.reload.deadline).to eq("2016-01-01".to_date)
      end
    end

    context "when updating fails" do
      let(:assignments_repository) do
        double(:assignments_repository, update: false)
      end

      it "returns error response" do
        expect(service.call).to be_kind_of(Response::Error)
      end

      it "does not change deadline" do
        service.call
        expect(assignment.reload.deadline).to be_nil
      end
    end
  end
end