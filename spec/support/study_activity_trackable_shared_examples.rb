require "support/matchers/have_latest_activity"

RSpec.shared_examples_for "study_activity_trackable" do
  # the class that includes the concern
  let(:model) { described_class.to_s.underscore.to_sym }

  before do
    PublicActivity.enabled = true
  end

  after do
    PublicActivity.enabled = false
  end

  it "logs an activity on the study when created" do
    study = FactoryGirl.create(:study)
    resource = FactoryGirl.create(model, study: study)
    study.reload
    expect(study.activities.length).to eq 2
    expect(study).to have_latest_activity("study.#{model}_added",
                                          type: described_class.to_s,
                                          id: resource.id)
  end

  it "logs an activity on the study if created via the study's association" do
    study = FactoryGirl.create(:study)
    association = study.send model.to_s.pluralize.to_sym
    # See https://github.com/thoughtbot/factory_girl/issues/359
    # We want to use FactoryGirl to get the attributes in a generic way, so
    # that we can then create a resource using the Study's association's
    # create method (e.g. study.documents.create(attrs)). But the usual
    # attributes_for will ignore any associations on the factory, so models
    # which need some other things building won't be valid.
    attrs = FactoryGirl.build(model).attributes.delete_if do |k, _v|
      %w(id study_id created_at updated_at).member?(k)
    end
    resource = association.create!(attrs)
    study.reload
    expect(study.activities.length).to eq 2
    expect(study).to have_latest_activity("study.#{model}_added",
                                          type: described_class.to_s,
                                          id: resource.id)
  end
end
