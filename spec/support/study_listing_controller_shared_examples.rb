require "rails_helper"

RSpec.shared_examples_for "study listing controller" do
  it "lists the studies" do
    get action, params
    expect(assigns[:studies]).to match_array(studies.last(10))
  end

  it "paginates the studies" do
    get action, params.merge(page: 2)
    expect(assigns[:studies]).to match_array(studies.first(10))
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
    let(:modelling_study) { FactoryGirl.create(:study, study_type: modelling_type) }
    let(:modelling_completion_study) { FactoryGirl.create(:study, study_type: modelling_type, study_stage: :completion, protocol_needed: false) }

    context "when no filters are applied" do
      # let(:params) { {} }

      it "sets nil filter values" do
        get action, params
        expect(assigns[:study_type]).to be nil
        expect(assigns[:study_stage]).to be nil
      end

      it "shows all studies" do
        get action, params
        if params[:user_id].blank?
          expected_studies = Study.all.last(10)
        else
          expected_studies = Study.where(principal_investigator_id: params[:user_id]).last(10)
        end
        expect(assigns[:studies]).to match_array expected_studies
      end
    end

    context "when filters are applied" do
      let(:extra_params) { {study_type: 'modelling', study_stage: 'completion'} }

      it "sets correct filter values" do
        get action, params.merge(extra_params)
        expect(assigns[:study_type]).to eq 'modelling'
        expect(assigns[:study_stage]).to eq 'completion'
      end

      it "shows only matching studies" do
        unless params[:user_id].blank?
          modelling_completion_study.principal_investigator_id = params[:user_id]
          modelling_completion_study.save
        end
        get action, params.merge(extra_params)
        expect(assigns[:studies]).to match_array [modelling_completion_study]
      end
    end

    it "displays correct filter options" do
      get action, params
      expect(assigns[:study_types]).to match_array StudyType.all
      expect(assigns[:study_topics]).to match_array StudyTopic.all
    end
  end
end
