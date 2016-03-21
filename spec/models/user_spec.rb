require "rails_helper"

RSpec.describe User, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:text).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:msf_location_id).of_type(:integer) }
  it { is_expected.to have_db_column(:external_location).of_type(:text) }
  it do
    is_expected.to have_db_column(:is_admin).of_type(:boolean).
      with_options(null: false, default: false)
  end
  it do
    is_expected.to have_db_column(:invite_token).of_type(:string).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:approved).of_type(:boolean).
      with_options(null: false, default: false)
  end
  it do
    is_expected.to have_db_column(:delivery_update_token).of_type(:string).
      with_options(null: false)
  end

  # Indexes
  it { is_expected.to have_db_index(:delivery_update_token).unique }

  # Associations
  it { is_expected.to belong_to(:msf_location).inverse_of(:users) }
  it do
    is_expected.to have_many(:principal_investigator_studies).
      inverse_of(:principal_investigator).class_name(:Study)
  end
  it do
    is_expected.to have_many(:research_manager_studies).
      inverse_of(:research_manager).class_name(:Study)
  end
  it do
    is_expected.to have_many(:created_activities).
      class_name("PublicActivity::Activity")
  end
  it do
    is_expected.to have_many(:involved_activities).
      class_name("PublicActivity::Activity")
  end
  it { is_expected.to have_many(:documents).inverse_of(:user) }
  it { is_expected.to have_many(:publications).inverse_of(:user) }
  it { is_expected.to have_many(:disseminations).inverse_of(:user) }
  it { is_expected.to have_many(:study_impacts).inverse_of(:user) }
  it { is_expected.to have_many(:study_notes).inverse_of(:user) }
  it { is_expected.to have_many(:sent_alerts).inverse_of(:user) }
  it do
    is_expected.to have_many(:created_study_invites).inverse_of(:inviting_user)
  end
  it do
    is_expected.to have_many(:received_study_invites).inverse_of(:invited_user)
  end
  it do
    is_expected.to have_many(:invited_studies).
      through(:received_study_invites).
      source(:study)
  end
  it { is_expected.to have_many(:delivery_updates).inverse_of(:user) }

  # Validation
  describe "validations" do
    subject { FactoryGirl.build(:user) }
    it { is_expected.to validate_presence_of(:name) }
    it do
      is_expected.to validate_inclusion_of(:is_admin).in_array([true, false])
    end
  end

  context "when the when msf_location field is 'External'" do
    let(:external_location) { MsfLocation.find_by_name("External") }

    it "should be invalid when the external_location field is nil" do
      user = FactoryGirl.build(:user)
      user.msf_location = external_location
      user.external_location = nil
      expect(user).to be_invalid
    end

    it "should be invalid when the external_location field is empty" do
      user = FactoryGirl.build(:user)
      user.msf_location = external_location
      user.external_location = ""
      expect(user).to be_invalid
    end

    it "should be valid when we set the external_location field" do
      user = FactoryGirl.build(:user)
      user.msf_location = external_location
      user.external_location = "some external location"
      expect(user).to be_valid
    end
  end

  context "when the user has owned some activities", :truncation do
    let(:user) { FactoryGirl.create(:user) }
    let(:study) { FactoryGirl.create(:study) }

    before do
      PublicActivity.enabled = true
      study.create_activity("title_changed", owner: user)
    end

    after do
      PublicActivity.enabled = false
    end

    it "should not allow the user to be deleted" do
      expected_error = ActiveRecord::DeleteRestrictionError
      expect { user.destroy }.to raise_error(expected_error)
    end
  end

  context "when the user is involved in some activities", :truncation do
    let(:user) { FactoryGirl.create(:user) }
    let(:study) { FactoryGirl.create(:study) }

    before do
      PublicActivity.enabled = true
      study.create_activity("principal_investigator_id_changed",
                            recipient: user)
    end

    after do
      PublicActivity.enabled = false
    end

    it "deletes the activities if the user is deleted" do
      expect { user.destroy }.to change(study.activities, :count).by(-1)
    end
  end

  describe "#studies" do
    let(:user) { FactoryGirl.create(:user) }
    let(:pi_studies) do
      FactoryGirl.create_list(:study, 5, principal_investigator: user)
    end
    let(:rm_studies) do
      FactoryGirl.create_list(:study, 5, research_manager: user)
    end
    let(:other_studies) do
      FactoryGirl.create_list(:study, 5)
    end
    let(:expected_studies) { pi_studies + rm_studies }

    it "lists all of the user's studies" do
      expect(user.studies).to match_array(expected_studies)
    end
  end

  describe "user approval" do
    context "when the user has an msf.org email address" do
      let(:user) do
        User.new(email: "test@msf.org",
                 name: "test user",
                 password: "password",
                 password_confirmation: "password")
      end

      before do
        ActionMailer::Base.deliveries = []
      end

      it "automatically approves them" do
        expect(user.approved?).to be true
      end

      it "doesn't send an email to the admins" do
        user.save!
        # confirmation mail for the user only
        expect(ActionMailer::Base.deliveries.length).to eq 1
      end
    end

    context "when the user has an subdomain.msf.org email address" do
      let(:user) do
        User.new(email: "test@london.msf.org",
                 name: "test user",
                 password: "password",
                 password_confirmation: "password")
      end

      before do
        ActionMailer::Base.deliveries = []
      end

      it "automatically approves them" do
        expect(user.approved?).to be true
      end

      it "doesn't send an email to the admins" do
        user.save!
        # confirmation mail for the user only
        expect(ActionMailer::Base.deliveries.length).to eq 1
      end
    end

    context "when the user has an non-MSF email address" do
      let!(:admin) { FactoryGirl.create(:admin_user) }
      let(:user) do
        User.new(email: "test@londonmsf.org",
                 name: "test user",
                 password: "password",
                 password_confirmation: "password")
      end

      before do
        ActionMailer::Base.deliveries = []
      end

      it "doesn't automatically approve them" do
        expect(user.approved?).to be false
      end

      it "emails admins about the new user" do
        user.save!
        # confirmation mail and then the admin mail
        expect(ActionMailer::Base.deliveries.length).to eq 2
        admin_mail = ActionMailer::Base.deliveries.last
        expect(admin_mail.to).to eq [admin.email]
        expect(admin_mail.subject).to eq "New user waiting for approval on " \
                                         "ReMIT: test@londonmsf.org"
      end

      context "when a user is subsequently approved" do
        it "sends an email to the user" do
          user.save!
          ActionMailer::Base.deliveries = []
          user.approved = true
          user.save!
          expect(ActionMailer::Base.deliveries.length).to eq 1
          mail = ActionMailer::Base.deliveries.last
          expect(mail.to).to eq [user.email]
          expect(mail.subject).to eq "Your account on ReMIT has been approved!"
        end
      end
    end
  end
end
