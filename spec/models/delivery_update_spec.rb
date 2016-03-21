require "rails_helper"

RSpec.describe DeliveryUpdate, type: :model do
  # Columns
  it { is_expected.to have_db_column(:study_id).of_type(:integer) }
  it do
    is_expected.to have_db_column(:data_analysis_status_id).of_type(:integer)
  end
  it do
    is_expected.to have_db_column(:data_collection_status_id).of_type(:integer)
  end
  it do
    is_expected.to have_db_column(:interpretation_and_write_up_status_id).
      of_type(:integer)
  end
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:comments).of_type(:text) }

  # Associations
  it { is_expected.to belong_to(:study).inverse_of(:delivery_updates) }
  it do
    is_expected.to belong_to(:data_analysis_status).
      class_name(:DeliveryUpdateStatus)
  end
  it do
    is_expected.to belong_to(:data_collection_status).
      class_name(:DeliveryUpdateStatus)
  end
  it do
    is_expected.to belong_to(:interpretation_and_write_up_status).
      class_name(:DeliveryUpdateStatus)
  end
  it { is_expected.to belong_to(:user).inverse_of(:delivery_updates) }
  it do
    is_expected.to have_many(:delivery_update_invites).
      inverse_of(:delivery_update)
  end

  # Validations
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:data_analysis_status) }
  it { is_expected.to validate_presence_of(:data_collection_status) }
  it do
    is_expected.to validate_presence_of(:interpretation_and_write_up_status)
  end
  it { is_expected.to validate_presence_of(:user) }

  describe "#delayed?" do
    let(:good) { FactoryGirl.create(:progressing_fine) }
    let(:medium) { FactoryGirl.create(:minor_problems) }
    let(:bad) { FactoryGirl.create(:major_problems) }
    let(:neutral) { FactoryGirl.create(:not_started) }
    let(:neutral2) { FactoryGirl.create(:completed) }
    let!(:delayed) { [medium, bad] }
    let!(:not_delayed) { [good, neutral, neutral2] }
    let(:update) { FactoryGirl.create(:delivery_update) }
    let(:status_fields) do
      %w(data_analysis_status
         data_collection_status
         interpretation_and_write_up_status)
    end

    context "when any status is delayed" do
      it "returns true" do
        delayed.each do |status|
          status_fields.each do |field|
            update.send("#{field}=".to_sym, status)
            update.save!
            expect(update.delayed?).to be true
          end
        end
      end
    end

    context "when no status is delayed" do
      it "returns false" do
        not_delayed.each do |status|
          status_fields.each do |field|
            update.send("#{field}=".to_sym, status)
          end
          update.save!
          expect(update.delayed?).to be false
        end
      end
    end
  end

  describe "#update_study callback" do
    let(:study) { FactoryGirl.create(:study) }

    it "calls study.save_delivery_delayed when created" do
      expect(study).to receive(:save_delivery_delayed)
      FactoryGirl.create(:delivery_update, study: study)
    end

    it "calls study.save_delivery_delayed when updated" do
      expect(study).to receive(:save_delivery_delayed).twice
      delivery_update = FactoryGirl.create(:delivery_update, study: study)
      delivery_update.save!
    end

    it "calls study.save_delivery_delayed when destroyed" do
      expect(study).to receive(:save_delivery_delayed).twice
      delivery_update = FactoryGirl.create(:delivery_update, study: study)
      delivery_update.destroy
    end
  end
end
