require 'rails_helper'

RSpec.describe "Api::Leaves", type: :request do
  fixtures :leave

  describe "GET /index" do
    it "returns http success" do
      get api_leaves_path
      expect(response).to have_http_status(:success)
    end

    it "returns the correct number of leaves" do
      get api_leaves_path
      expected_count = Leave.count
      expect(json.size).to eq(expected_count)
    end

    it "returns the correct leaves" do
      get api_leaves_path
      expected_leaves = Leave.all.map(&:as_json)
      expect(json).to match_array(expected_leaves)
    end
  end

  describe "GET /show" do
    context "when the leave exists" do
      it "returns http success" do
        get api_leave_path(leave(:one).id)
        expect(response).to have_http_status(:success)
      end

      it "returns the correct leave" do
        get api_leave_path(leave(:one).id)
        expect(json).to eq(leave(:one).as_json)
      end
    end

    context "when the leave does not exist" do
      it "returns http not found" do
        get api_leave_path(999999)
        expect(response).to have_http_status(:not_found)
      end

      it "returns the correct error message" do
        get api_leave_path(999999)
        expect(json).to eq("error" => "Leave not found")
      end
    end
  end

  describe "POST /create" do
    subject { post api_leaves_path, params: params }

    context "with valid parameters" do
      let(:params) { { leave: { start_date: Date.today, end_date: Date.today + 1.day, leave_type: "vacations", state: "pending" } } }

      it "returns http created" do
        subject
        expect(response).to have_http_status(:created)
      end

      it "increases the number of leaves" do
        expect { subject }.to change(Leave, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:params) { { leave: { start_date: Date.today, end_date: Date.today - 1.day, leave_type: "vacations", state: "pending" } } }

      it "returns http unprocessable content" do
        subject
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns the correct error message" do
        subject
        expect(json).to eq(["End date must be greater than or equal to start date"])
      end
    end
  end

  describe "PATCH /update" do
    subject { patch api_leave_path(leave(:one).id), params: params }

    context "when want to update the state of the leave" do
      let(:params) { { leave: { state: "approved" } } }

      it "update the state of the leave" do
        subject
        expect(leave(:one).reload.state).to eq("approved")
      end

      it "returns http success" do
        subject
        expect(response).to have_http_status(:success)
      end
    end

    context "with valid parameters" do
      let(:params) { { leave: { start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 1, 2), leave_type: "medical", state: "pending" } } }

      it "returns http success" do
        subject
        expect(response).to have_http_status(:success)
      end

      it "returns the correct leave" do
        subject
        expect(json).to eq(leave(:one).reload.as_json)
      end
    end

    context "with invalid parameters" do
      let(:params) { { leave: { start_date: Date.today, end_date: Date.today - 1.day, leave_type: "vacations", state: "pending" } } }

      it "returns http unprocessable content" do
        subject
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when the leave does not exist" do
      it "returns http not found" do
        patch api_leave_path(999999), params: { leave: { state: "approved" } }
        expect(response).to have_http_status(:not_found)
      end
      
      it "returns the correct error message" do
        patch api_leave_path(999999), params: { leave: { state: "approved" } }
        expect(json).to eq("error" => "Leave not found")
      end
    end
  end

  describe "DELETE /destroy" do
    context "when the leave exists" do
      subject { delete api_leave_path(leave(:one).id) }

      it "returns http no_content" do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it "decreases the number of leaves" do
        expect { subject }.to change(Leave, :count).by(-1)
      end
    end
    context "when the leave does not exist" do
      it "returns http not found" do
        delete api_leave_path(999999)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
