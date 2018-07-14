# frozen_string_literal: true

RSpec.describe 'Generate items from XML' do
  it 'create IsoBibliographicItem from XML' do
    xml = File.read 'spec/examples/iso_bib_item.xml'
    item = IsoBibItem.from_xml xml
    expect(item).to be_instance_of IsoBibItem::IsoBibliographicItem 
  end
end
