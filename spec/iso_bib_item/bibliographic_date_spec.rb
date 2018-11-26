# forzen_string_literal: true

require "iso_bib_item/bibliographic_item"

RSpec.describe IsoBibItem::BibliographicDate do
  it "parse yyyy-mm format date" do
    date = IsoBibItem::BibliographicDate.new(
      type: "published",
      on: "2014-11"
    )
    expect(date.on).to eq Time.strptime "2014-11", "%Y-%m"
  end
end