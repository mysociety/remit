require 'rails_helper'

RSpec.describe "home/index.html.erb", type: :view do
  it "should print the name of the project" do
    render
    expect(rendered).to match /ReMIT/
  end
end
