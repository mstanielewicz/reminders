require "rails_helper"

describe Project do
  describe "ActiveModel validations" do
    let(:project) { create(:project) }
    it { expect(project).to validate_presence_of(:email) }
  end
end