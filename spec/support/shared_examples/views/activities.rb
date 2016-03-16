RSpec.shared_examples_for "an activity view" do
  context "given an activity with an owner" do
    before do
      render partial: partial,
             locals: { a: activity_with_owner,
                       p: activity_with_owner.parameters }
    end

    it "renders the owner's name" do
      expected_text = " by #{activity_with_owner.owner.name}"
      expect(view.content_for(:title)).to have_text expected_text
    end
  end

  context "given an activity without an owner" do
    before do
      render partial: partial,
             locals: { a: activity_without_owner,
                       p: activity_without_owner.parameters }
    end

    it "doesn't render the owner's name" do
      expect(view.content_for(:title)).not_to have_text " by "
    end
  end

  context "given an activity" do
    before do
      render partial: partial,
             locals: { a: activity_with_owner,
                       p: activity_with_owner.parameters }
    end

    it "sets the right class" do
      if expected_class.nil?
        expect(view.content_for(:extra_classes)).to be nil
      else
        expect(view.content_for(:extra_classes)).to have_text expected_class
      end
    end

    it "sets the title" do
      expect(view.content_for(:title)).to have_text expected_title
    end

    it "sets the description" do
      if expected_description.nil?
        expect(view.content_for(:description)).to be nil
      else
        expect(view.content_for(:description)).to(
          have_text(expected_description))
        expect(view.content_for(:description)).to(
          have_css(expected_description_class))
      end
    end
  end
end
