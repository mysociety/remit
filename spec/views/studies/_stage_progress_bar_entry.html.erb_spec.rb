require "rails_helper"

RSpec.describe "studies/_stage_progress_bar_entry.html.erb", type: :view do
  it "renders a blank entry when the state is empty" do
    render partial: "studies/stage_progress_bar_entry",
           locals: { label: "Test", state: "" }
    expect(rendered).to have_css "li"
    expect(rendered).to have_text "Test"
    expect(rendered).not_to have_css "li.step--doing"
    expect(rendered).not_to have_css "li.step--done"
    expect(rendered).not_to have_css "img"
  end

  it "renders a 'doing' entry when the state is doing" do
    render partial: "studies/stage_progress_bar_entry",
           locals: { label: "Test", state: "doing" }
    expect(rendered).to have_css "li.step--doing"
    expect(rendered).not_to have_css "img"
    expect(rendered).to have_text "Test"
  end

  it "renders a 'done' entry when the state is done" do
    render partial: "studies/stage_progress_bar_entry",
           locals: { label: "Test", state: "done" }
    expect(rendered).to have_css "li.step--done"
    expect(rendered).to have_css "img"
    expect(rendered).to have_text "Test"
  end
end
