# frozen_string_literal: true

require 'iso_bib_item/bibliographic_item'

RSpec.describe IsoBibItem::BibliographicItem do
  let(:bib_item) do
    IsoBibItem::BibliographicItem.new(
      id:     'ISO/TC211',
      fetched: '2018-10-03',
      titles: [
        { content: 'Geographic information', language: 'en', script: 'Latn' },
        { content: 'Information géographique', language: 'fr', script: 'Latn' }
      ],
      docid: [
        IsoBibItem::DocumentIdentifier.new(id: 'TC211', type: 'ISO')
      ],
      edition:   '1',
      language:  %w[en fr],
      script:    ['Latn'],
      type:      'international-standard',
      docstatus: IsoBibItem::DocumentStatus.new(
        IsoBibItem::LocalizedString.new('standard')
      ),
      workgroup: { name: 'International Organization for Standardization',
                   abbreviation: 'ISO', url: 'www.iso.org/',
                   technical_committee: {
                     name: ' ISO/TC 211 Geographic information/Geomatics',
                     type: 'technicalCommittee', number: 211
                   } },
      ics:       [{ field: 35, group: 240, subgroup: 70 }],
      dates:     [{ type: 'published', from: '2014-04' }],
      abstract:  [
        { content: 'ISO 19115-1:2014 defines the schema required for ...',
          language: 'en', script: 'Latn', type: 'plain' },
        { content: "L'ISO 19115-1:2014 définit le schéma requis pour ...",
          language: 'fr', script: 'Latn', type: 'plain' }
      ],
      contributors: [
        { entity: { name: 'International Organization for Standardization',
                    url: 'www.iso.org', abbreviation: 'ISO' },
          roles: ['publisher'] },
        { entity: IsoBibItem::Person.new(
            name: IsoBibItem::FullName.new(
              completename: localized_string('A. Bierman')
            ),
            affiliation: [IsoBibItem::Affilation.new(
              IsoBibItem::Organization.new(name: 'IETF', abbreviation: 'IETF')
            )],
            contacts: [
              IsoBibItem::Address.new(
                street: ['Street'], city: 'City', postcode: '123456',
                country: 'Country', state: 'State'
              ),
              IsoBibItem::Contact.new(type: 'phone', value: '223322')
            ]
          ),
          roles: ['author']
        },
        { entity: IsoBibItem::Person.new(
            name: IsoBibItem::FullName.new(
              initials: [localized_string('A.')],
              surname: localized_string('Bierman')
            ),
            affiliation: [IsoBibItem::Affilation.new(
              IsoBibItem::Organization.new(name: 'IETF', abbreviation: 'IETF')
            )],
            contacts: [
              IsoBibItem::Address.new(
                street: ['Street'], city: 'City', postcode: '123456',
                country: 'Country', state: 'State'
              ),
              IsoBibItem::Contact.new(type: 'phone', value: '223322')
            ]
          ),
          roles: ['author']
        }
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
      ],
      series: [
        IsoBibItem::Series.new(
          type: 'main',
          title: IsoBibItem::FormattedString.new(
            content: 'ISO/IEC FDIS 10118-3', language: 'en', script: 'Latn'
          )
        )
      ]
    )
  end

  it 'create BibliographicItem' do
    expect(bib_item).to  be_instance_of IsoBibItem::BibliographicItem
    expect(bib_item.title).to be_instance_of Array
    file = 'spec/examples/bib_item.xml'
    File.write file, bib_item.to_xml unless File.exist? file
    expect(bib_item.to_xml).to be_equivalent_to File.read file
  end

  it 'create IsoBibliographicItem from XML' do
    xml = File.read 'spec/examples/iso_bib_item.xml'
    xml.gsub! '<fetched>2018-10-21</fetched>', "<fetched>#{Date.today}</fetched>"
    item = IsoBibItem::XMLParser.from_xml xml
    expect(item).to be_instance_of IsoBibItem::IsoBibliographicItem
    expect(item.to_xml).to be_equivalent_to xml
  end


  private

  # @param content [String]
  # @return [IsoBibItem::LocalizedString]
  def localized_string(content, lang = 'en')
    IsoBibItem::LocalizedString.new(content, lang)
  end
end
