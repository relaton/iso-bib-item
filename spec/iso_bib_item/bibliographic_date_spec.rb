# forzen_string_literal: true

require "iso_bib_item/bibliographic_item"

RSpec.describe IsoBibItem::BibliographicDate do
  context "date on given" do
    subject do
      IsoBibItem::BibliographicDate.new(type: "published", on: "2014-11")
    end

    it "parse yyyy-mm format date" do
      expect(subject.on).to eq Time.strptime "2014-11", "%Y-%m"
    end

    it "returns xml string" do
      xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        subject.to_xml xml
      end.doc.root.to_xml
      expect(xml).to be_equivalent_to '<date type="published"><on>2014</on></date>'
    end

    it "returns xml string with full date" do
      xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        subject.to_xml xml, full_date: true
      end.doc.root.to_xml
      expect(xml).to be_equivalent_to '<date type="published"><on>2014-11</on></date>'
    end
  end

  context "dates from and to given" do
    subject do
      IsoBibItem::BibliographicDate.new(type: "published", from: "2014-11", to: "2015-12")
    end

    it "returns xml string" do
      xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        subject.to_xml xml
      end.doc.root.to_xml
      expect(xml).to be_equivalent_to '<date type="published"><from>2014</from><to>2015</to></date>'
    end

    it "returns xml string with full date" do
      xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        subject.to_xml xml, full_date: true
      end.doc.root.to_xml
      expect(xml).to be_equivalent_to '<date type="published"><from>2014-11</from><to>2015-12</to></date>'
    end
  end
end
