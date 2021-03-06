# encoding: UTF-8
# frozen_string_literal: true

require 'iso_bib_item/iso_bibliographic_item'

def generate_item
  IsoBibItem::IsoBibliographicItem.new(
    docid:  { project_number: "ISO 1", part_number: 2, prefix: nil, id: "ISO 1-2:2014" },
    titles: [
      { title_intro: 'Geographic information', title_main: 'Metadata',
        title_part: 'Part 1: Fundamentals', language: 'en', script: 'Latn' },
      { title_intro: 'Information géographique', title_main: 'Métadonnées',
        title_part: 'Information géographique', language: 'fr',
        script: 'Latn' }
    ],
    edition:   '1',
    language:  %w[en fr],
    script:    ['Latn'],
    type:      'international-standard',
    docstatus: { status: 'Published', stage: '60', substage: '60' },
    workgroup: { name: 'International Organization for Standardization',
                  abbreviation: 'ISO', url: 'www.iso.org/',
                  technical_committee: {
                    name: ' ISO/TC 211 Geographic information/Geomatics',
                    type: 'technicalCommittee', number: 211
                  } },
    ics:       [{ field: 35, group: 240, subgroup: 70 }],
    dates:     [{ type: 'published', on: '2014-04' }],
    abstract:  [
      { content: 'ISO 19115-1:2014 defines the schema required for ...',
        language: 'en', script: 'Latn', type: 'plain' },
      { content: "L'ISO 19115-1:2014 définit le schéma requis pour ...",
        language: 'fr', script: 'Latn', type: 'plain' }
    ],
    contributors: [
      { entity: { name: 'International Organization for Standardization',
                  url: 'www.iso.org', abbreviation: 'ISO' },
        roles: ['publisher'] }
    ],
    copyright:   { owner: {
      name: 'International Organization for Standardization',
      abbreviation: 'ISO', url: 'www.iso.org'
    }, from: '2014' },
    link: [
      { type: 'src', content: 'https://www.iso.org/standard/53798.html' },
      { type: 'obp',
        content: 'https://www.iso.org/obp/ui/#!iso:std:53798:en' },
      { type: 'rss', content: 'https://www.iso.org/contents/data/standard'\
        '/05/37/53798.detail.rss' }
    ],
    relations: [
      { type: 'updates', identifier: 'ISO 19115:2003',
        url: 'https://www.iso.org/standard/26020.html' },
      { type: 'updates', identifier: 'ISO 19115:2003/Cor 1:2006',
        url: 'https://www.iso.org/standard/44361.html' }
    ]
  )
end

RSpec.describe IsoBibItem::IsoBibliographicItem do
=begin
  let(:iso_bib_item) do
    IsoBibItem::IsoBibliographicItem.new(
      docid:  { project_number: 1, part_number: 2 },
      titles: [
        { title_intro: 'Geographic information', title_main: 'Metadata',
          title_part: 'Part 1: Fundamentals', language: 'en', script: 'Latn' },
        { title_intro: 'Information géographique', title_main: 'Métadonnées',
          title_part: 'Information géographique', language: 'fr',
          script: 'Latn' }
      ],
      edition:   '1',
      language:  %w[en fr],
      script:    ['Latn'],
      type:      'international-standard',
      docstatus: { status: 'Published', stage: '60', substage: '60' },
      workgroup: { name: 'International Organization for Standardization',
                   abbreviation: 'ISO', url: 'www.iso.org/',
                   technical_committee: {
                     name: ' ISO/TC 211 Geographic information/Geomatics',
                     type: 'technicalCommittee', number: 211
                   } },
      ics:       [{ field: 35, group: 240, subgroup: 70 }],
      dates:     [{ type: 'published', on: '2014-04' }],
      abstract:  [
        { content: 'ISO 19115-1:2014 defines the schema required for ...',
          language: 'en', script: 'Latn', type: 'plain' },
        { content: "L'ISO 19115-1:2014 définit le schéma requis pour ...",
          language: 'fr', script: 'Latn', type: 'plain' }
      ],
      contributors: [
        { entity: { name: 'International Organization for Standardization',
                    url: 'www.iso.org', abbreviation: 'ISO' },
          roles: ['publisher'] }
      ],
      copyright:   { owner: {
        name: 'International Organization for Standardization',
        abbreviation: 'ISO', url: 'www.iso.org'
      }, from: '2014' },
      link: [
        { type: 'src', content: 'https://www.iso.org/standard/53798.html' },
        { type: 'obp',
          content: 'https://www.iso.org/obp/ui/#!iso:std:53798:en' },
        { type: 'rss', content: 'https://www.iso.org/contents/data/standard'\
          '/05/37/53798.detail.rss' }
      ],
      relations: [
        { type: 'updates', identifier: 'ISO 19115:2003',
          url: 'https://www.iso.org/standard/26020.html' },
        { type: 'updates', identifier: 'ISO 19115:2003/Cor 1:2006',
          url: 'https://www.iso.org/standard/44361.html' }
      ]
    )
  end
=end

  it 'create IsoBibliographicItem' do
    iso_bib_item = generate_item
    expect(iso_bib_item).to be_instance_of IsoBibItem::IsoBibliographicItem
    expect(iso_bib_item.title).to be_instance_of Array
    expect(iso_bib_item.title(lang: 'en').title_main).to eq 'Metadata'
    expect(iso_bib_item.url).to eq 'https://www.iso.org/standard/53798.html'
    expect(iso_bib_item.url(:rss)).to eq 'https://www.iso.org/contents/data/'\
                                         'standard/05/37/53798.detail.rss'
    expect(iso_bib_item.relations.replaces).to be_instance_of Array
    expect(iso_bib_item.abstract(lang: 'en')).to be_instance_of(
      IsoBibItem::FormattedString
    )

    expect(iso_bib_item.shortref(
      iso_bib_item.docidentifier.first
    )).to eq "ISO 1-2-2014:2014"

    expect(iso_bib_item.shortref(
      iso_bib_item.docidentifier.first, { no_year: true }
    )).to eq "ISO 1-2-2014"

    expect(iso_bib_item.contributors.first.entity.url).to eq "www.iso.org"

    file = 'spec/examples/iso_bib_item.xml'
    File.write file, iso_bib_item.to_xml, encoding: 'utf-8' unless File.exist? file
    xml = File.read file, encoding: 'UTF-8'
    xml.gsub! '<fetched>2018-10-21</fetched>', "<fetched>#{Date.today}</fetched>"
    expect(iso_bib_item.to_xml).to be_equivalent_to xml

    file = 'spec/examples/iso_bib_item_note.xml'
    File.write file, iso_bib_item.to_xml(note: 'test note'), encoding: 'utf-8' unless File.exist? file
    xml_res = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |builder|
      iso_bib_item.to_xml builder, note: 'test note'
    end.doc.root.to_xml
    xml = File.read file, encoding: "UTF-8"
    xml.gsub! "<fetched>2018-10-21</fetched>", "<fetched>#{Date.today}</fetched>"
    expect(xml_res).to be_equivalent_to xml
    expect(iso_bib_item.dates.filter(type: "published").first).to be_instance_of IsoBibItem::BibliographicDate
  end

  it "converts to all_parts reference" do
    iso_bib_item = generate_item
    expect(iso_bib_item.title.first.title_part).not_to be nil
    expect(iso_bib_item.relations.last.type).not_to eq "partOf"
    expect(iso_bib_item.to_xml).not_to include "<allparts>true</allparts>"
    expect(iso_bib_item.to_xml).to include "<bibitem type=\"international-standard\" id=\"ISO1-2-2014\">"
    iso_bib_item.to_all_parts
    expect(iso_bib_item.relations.last.type).to eq "partOf"
    expect(iso_bib_item.title.first.title_part).to be nil
    expect(iso_bib_item.to_xml).to include "<allparts>true</allparts>"
    expect(iso_bib_item.to_xml).to include "<bibitem type=\"international-standard\" id=\"ISO1-2014(allparts)\">"
  end

  it "converts to latest year reference" do
    iso_bib_item = generate_item
    expect(iso_bib_item.title.first.title_part).not_to be nil
    expect(iso_bib_item.relations.last.type).not_to eq "instance"
    expect(iso_bib_item.dates).not_to be_empty
    iso_bib_item.to_most_recent_reference
    expect(iso_bib_item.relations.last.type).to eq "instance"
    expect(iso_bib_item.dates).to be_empty
  end

  it "raise error when there is no ICS code and field" do
    expect { IsoBibItem::Ics.new }.to raise_error ArgumentError
  end

  it "doc identifier remove part/date" do
    docid = IsoBibItem::IsoDocumentId.new(id: "GB 1.2-2014", type: "Chinese Standard")
    docid.remove_part
    expect(docid.id).to eq "GB 1-2014"
    docid.remove_date
    expect(docid.id).to eq "GB 1"
  end

  it "rise error if there is no surname and completename" do
    expect { IsoBibItem::FullName.new }.to raise_error ArgumentError
  end
end
