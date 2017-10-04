require "rails_helper"
require "support/devise"

RSpec.shared_examples_for "study listing controller" do
  before do
    studies.sort! { |a, b| a.created_at <=> b.created_at }
  end

  it "lists the studies" do
    get action, params
    expect(assigns[:studies]).to match_array(studies.last(10))
  end

  it "paginates the studies" do
    get action, params.merge(page: 2)
    expect(assigns[:studies]).to match_array(studies.first(10))
  end

  it "offers a CSV download of the studies" do
    get action, params.merge(format: :csv)
    csv = CSV.parse(response.body)
    expect(csv.first).to match_array(Study.csv_headers)
    expect(csv.length).to eq studies.length + 1
  end

  describe "#set_study_scope" do
    it "sets study_scope" do
      get action, params
      expect(assigns[:study_scope]).to eq :not_archived_or_withdrawn
    end

    context "when the user asks for archived studies too" do
      before do
        params[:include_archived] = 1
      end

      it "sets study_scope" do
        get action, params
        expect(assigns[:study_scope]).to eq :not_withdrawn
      end
    end
  end

  describe "#set_include_archived" do
    it "sets include_archived" do
      get action, params
      expect(assigns[:include_archived]).to be false
    end

    context "when the user asks for archived studies too" do
      before do
        params[:include_archived] = 1
      end

      it "sets study_scope" do
        get action, params
        expect(assigns[:include_archived]).to be true
      end
    end
  end

  describe "#set_filter_form_values" do
    let(:modelling_type) { FactoryGirl.create(:modelling_type) }
    let(:modelling_study) do
      FactoryGirl.create(:study, study_type: modelling_type)
    end
    let(:modelling_completion_study) do
      FactoryGirl.create(:study, study_type: modelling_type,
                                 study_stage: :completion,
                                 protocol_needed: false)
    end
    let(:modelling_delivery_study) do
      FactoryGirl.create(:study, study_type: modelling_type,
                                 study_stage: :delivery,
                                 protocol_needed: false)
    end

    context "when no filters are applied" do
      it "sets nil filter values" do
        get action, params
        expect(assigns[:selected_study_types]).to eq []
        expect(assigns[:selected_study_stages]).to eq []
      end

      it "shows all studies" do
        get action, params
        if params[:user_id].blank?
          expected_studies = Study.all.last(10)
        else
          sql = <<-SQL
            principal_investigator_id = ? OR research_manager_id = ?
          SQL
          pi_studies = Study.where(sql, params[:user_id], params[:user_id])
          expected_studies = pi_studies.last(10)
        end
        expect(assigns[:studies]).to match_array expected_studies
      end
    end

    context "when filters are applied" do
      # These specs use two filters at a time to make the expected results
      # smaller and easier to deal with (there's loads of other studies
      # created higher up)
      let(:extra_params) do
        { study_type: ["modelling"], study_stage: ["completion"] }
      end

      it "sets correct filter values" do
        get action, params.merge(extra_params)
        expect(assigns[:selected_study_types]).to eq ["modelling"]
        expect(assigns[:selected_study_stages]).to eq ["completion"]
      end

      it "shows only matching studies" do
        unless params[:user_id].blank?
          pid = params[:user_id]
          modelling_completion_study.principal_investigator_id = pid
          modelling_completion_study.save
        end
        get action, params.merge(extra_params)
        expect(assigns[:studies]).to match_array [modelling_completion_study]
      end
    end

    context "when multiple filters are applied" do
      # These specs use two filters at a time to make the expected results
      # smaller and easier to deal with (there's loads of other studies
      # created higher up)
      let(:extra_params) do
        { study_type: ["modelling"], study_stage: %w(completion delivery) }
      end

      it "sets correct filter values" do
        get action, params.merge(extra_params)
        expect(assigns[:selected_study_stages]).to match_array(
          %w(completion delivery)
        )
      end

      it "shows only matching studies" do
        unless params[:user_id].blank?
          pid = params[:user_id]
          modelling_completion_study.principal_investigator_id = pid
          modelling_completion_study.save
          modelling_delivery_study.principal_investigator_id = pid
          modelling_delivery_study.save
        end
        get action, params.merge(extra_params)
        expect(assigns[:studies]).to match_array(
          [modelling_completion_study, modelling_delivery_study]
        )
      end
    end

    it "displays correct filter options" do
      get action, params
      expect(assigns[:study_types]).to match_array StudyType.all
      expect(assigns[:study_topics]).to match_array StudyTopic.all
    end
  end

  context "#ordering_results" do
    before do
      Study.destroy_all
      # Created a long time ago, updated recently
      @study1 = FactoryGirl.create(
        :study,
        updated_at: 1.week.ago,
        created_at: 6.months.ago,
        principal_investigator_id: params[:user_id])
      # Created and updated a short while ago,
      # i.e. between the created/updated dates of @study1
      @study2 = FactoryGirl.create(
        :study,
        updated_at: 3.months.ago,
        created_at: 3.months.ago,
        principal_investigator_id: params[:user_id])
    end

    it "defaults to ordering by most recently created" do
      get action, params
      expect(assigns[:studies].first).to eq @study2
      expect(assigns[:studies].last).to eq @study1
    end

    it "can be ordered by updated_at" do
      get action, params.merge(order: "updated")
      expect(assigns[:studies].first).to eq @study1
      expect(assigns[:studies].last).to eq @study2
    end

    it "can be ordered by created_at" do
      get action, params.merge(order: "created")
      expect(assigns[:studies].first).to eq @study2
      expect(assigns[:studies].last).to eq @study1
    end
  end

  context "searching by various fields" do
    before do
      Study.destroy_all
      topic = StudyTopic.find_by_name("Brucellosis") ||
              FactoryGirl.create(:brucellosis)
      @study = FactoryGirl.create(
        :study,
        operating_center: "OCA",
        generated_reference_id: "12-34",
        country_codes: ["ZW"],
        title: "water sanitation study",
        study_topics: [topic],
        principal_investigator_id: params[:user_id])
    end

    it "allows searching by title" do
      get action, params.merge(q: "sanitation")
      expect(assigns[:studies]).to include @study
    end

    it "allows searching by PI name" do
      # Not all calling specs will have set a user
      unless params[:user_id]
        @study.principal_investigator = FactoryGirl.create(:user)
        @study.save!
      end
      get action, params.merge(q: @study.principal_investigator.name)
      expect(assigns[:studies]).to include @study
    end

    it "allows searching by topic" do
      get action, params.merge(q: "brucellosis")
      expect(assigns[:studies]).to include @study
    end

    it "allows searching by country" do
      get action, params.merge(q: "zimbabwe")
      expect(assigns[:studies]).to include @study
    end

    it "allows searching by reference number" do
      get action, params.merge(q: "OCA12-34")
      expect(assigns[:studies]).to include @study
    end
  end
end

RSpec.shared_examples_for "hidden study listing controller" do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin_user) }
  let(:pi) { FactoryGirl.create(:user) }
  let(:rm) { FactoryGirl.create(:user) }
  let(:hidden) do
    FactoryGirl.create(
      :study,
      hidden: true,
      principal_investigator_id: pi.id,
      research_manager_id: rm.id
    )
  end

  context "when a user is the study PI" do
    it "includes hidden studies" do
      sign_in pi
      get :index
      expect(assigns[:studies]).to include(hidden)
    end
  end

  context "when a user is the study RM" do
    it "includes hidden studies" do
      sign_in rm
      get :index
      expect(assigns[:studies]).to include(hidden)
    end
  end

  context "when a user is an admin" do
    it "includes hidden studies" do
      sign_in admin
      get :index
      expect(assigns[:studies]).to include(hidden)
    end
  end

  context "when a user is a normal user" do
    it "excludes hidden studies" do
      sign_in user
      get :index
      expect(assigns[:studies]).not_to include(hidden)
    end
  end

  context "when a user is logged out" do
    it "excludes hidden studies" do
      sign_out :user
      get :index
      expect(assigns[:studies]).not_to include(hidden)
    end
  end
end
