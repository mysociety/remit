require "rails_helper"

RSpec.shared_examples_for "content form view" do
  before do
    resource.valid?
    assign(:study, study)
    assign(resource_name, resource)
    render
  end

  it "prints an error message" do
    expect(rendered).to have_text expected_error
  end

  it "opens the right form" do
    expect(rendered).to have_checked_field(form_field)
  end
end
