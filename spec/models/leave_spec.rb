require 'rails_helper'

RSpec.describe Leave, type: :model do
  it "is valid with valid attributes" do
    leave = Leave.new(
      start_date: Date.today,
      end_date: Date.today + 1.day,
      leave_type: "vacations",
      state: "pending"
      )
    expect(leave).to be_valid
  end

  it "is invalid if end date is before start date" do
    leave = Leave.new(
      start_date: Date.today,
      end_date: Date.today - 1.day,
      leave_type: "vacations",
      state: "pending"
      )
    expect(leave).to be_invalid
  end

  it "is invalid if leave type is not in the list" do
    leave = Leave.new(
      start_date: Date.today,
      end_date: Date.today + 1.day,
      leave_type: "invalid",
      state: "pending"
      )
    expect(leave).to be_invalid
  end

  it "is invalid if state is not in the list" do
    leave = Leave.new(
      start_date: Date.today,
      end_date: Date.today + 1.day,
      leave_type: "vacations",
      state: "invalid"
      )
    expect(leave).to be_invalid
  end
end
