require "rails_helper"

RSpec.describe "studies/_stage_progress_bar_entry.html.erb", type: :view do
  it "renders a todo entry when the state is todo" do
    render partial: "studies/stage_progress_bar_entry",
           locals: { label: "Test", state: "todo", stage: :completion }
    expect(rendered).to have_css "li"
    expect(rendered).to have_text "Test"
    expect(rendered).to have_css "li.step--todo"
    expect(rendered).not_to have_css "img"
  end

  it "renders a 'doing' entry when the state is doing" do
    render partial: "studies/stage_progress_bar_entry",
           locals: { label: "Test", state: "doing", stage: :concept }
    expect(rendered).to have_css "li.step--doing"
    expect(rendered).not_to have_css "img"
    expect(rendered).to have_text "Test"
  end

  it "renders a 'done' entry when the state is done" do
    render partial: "studies/stage_progress_bar_entry",
           locals: { label: "Test", state: "done", stage: :concept }
    expect(rendered).to have_css "li.step--done"
    expect(rendered).to have_css "img"
    expect(rendered).to have_text "Test"
  end
end
