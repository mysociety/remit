RSpec.shared_examples_for "simple model admin" do
  # We need these two stages just for the admin dashboard to work
  let!(:completion_stage) { FactoryGirl.create(:completion_stage) }
  let!(:withdrawn_stage) { FactoryGirl.create(:withdrawn_postponed_stage) }
  let(:admin_user) { FactoryGirl.create(:admin_user) }

  before do
    sign_in_account(admin_user.email)
    click_link plural_resource_name
  end

  it "allows you to create a new resource" do
    click_link "New #{singular_resource_name}"
    name = "A New #{singular_resource_name}"
    fill_in "Name", with: name
    fill_in_extra_required_fields

    click_button "Create #{singular_resource_name.capitalize}"
    expected_text = "#{singular_resource_name.capitalize} was successfully " \
                    "created"
    expect(page).to have_text expected_text
    resource = resource_class.find_by_name(name)
    expect(resource).not_to be nil
  end

  context "with an existing resource" do
    let!(:resource) do
      attributes = FactoryGirl.attributes_for(resource_factory)
      existing = resource_class.find_by_name(attributes[:name])
      existing || FactoryGirl.create(resource_factory)
    end

    before do
      # An easy way to refresh the page
      click_link "#{plural_resource_name}"
    end

    it "allows you to edit the resource" do
      click_link "Edit", href: edit_polymorphic_path([:admin, resource])
      new_name = "Changed #{singular_resource_name}"
      fill_in "Name", with: new_name
      click_button "Update #{singular_resource_name.capitalize}"
      expected_text = "#{singular_resource_name.capitalize} was successfully" \
                      " updated"
      expect(page).to have_text expected_text
      expect(resource.reload.name).to eq new_name
    end

    it "allows you to delete the resource" do
      click_link "Delete", href: polymorphic_path([:admin, resource])
      expected_text = "#{singular_resource_name.capitalize} was successfully" \
                      " destroyed"
      expect(page).to have_text expected_text
      expect(resource_class.find_by_name(resource.name)).to be nil
    end
  end
end
