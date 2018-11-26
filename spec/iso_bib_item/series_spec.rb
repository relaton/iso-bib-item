# frozen_string_literal: true

require "iso_bib_item/series"

RSpec.describe IsoBibItem::Series do
  it "rise error when there is no title argunent" do
    expect { IsoBibItem::Series.new }.to raise_error ArgumentError
  end
end
