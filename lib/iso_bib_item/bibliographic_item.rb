# frozen_string_literal: true

require 'iso_bib_item/formatted_string'
require 'iso_bib_item/contribution_info'
require 'iso_bib_item/bibliographic_date'

module IsoBibItem
  # module BibItemType
  #   ARTICLE      = 'article'
  #   BOOK         = 'book'
  #   BOOKLET      = 'booklet'
  #   CONFERENCE   = 'conference'
  #   MANUAL       = 'manual'
  #   PROCEEDINGS  = 'proceedings'
  #   PRESENTATION = 'presentation'
  #   THESIS       = 'thesis'
  #   TECHREPORT   = 'techreport'
  #   STANDARD     = 'standard'
  #   UNPUBLISHED  = 'unpublished'
  # end

  # Document identifier.
  class DocumentIdentifier
    # @return [String]
    attr_reader :id

    # @return [String]
    attr_reader :type

    def initialize(id)
      @id = id
    end
  end

  # Copyright association.
  class CopyrightAssociation
    # @return [Time]
    attr_reader :from

    # @return [Time]
    attr_reader :to

    # @return [Isobib::ContributionInfo]
    attr_reader :owner

    # @param owner [Hash{name=>String, abbreviation=>String, url=>String}]
    #   contributor
    # @param from [String] date
    # @param to [String] date
    def initialize(owner:, from:, to: nil)
      @owner = ContributionInfo.new entity: Organization.new(owner)
      @from  = Time.strptime(from, '%Y') unless from.empty?
      @to    = Time.parse(to) if to
    end

    def to_xml(builder)
      builder.copyright do
        builder.from from.year
        builder.to to.year if to
        builder.owner { owner.to_xml builder }
      end
    end
  end

  # Typed URI
  class TypedUri
    # @return [Symbol] :src/:obp/:rss
    attr_reader :type
    # @retutn [URI]
    attr_reader :content

    # @param type [String] src/obp/rss
    # @param content [String]
    def initialize(type:, content:)
      @type    = type
      @content = URI content if content
    end

    def to_xml(builder)
      builder.link(content.to_s, type: type)
    end
  end

  # Bibliographic item
  class BibliographicItem
    # @return [String]
    attr_reader :id

    # @return [Array<IsoBibItem::FormattedString>]
    attr_reader :title

    # @return [Array<IsoBibItem::TypedUri>]
    attr_reader :link

    # @return [IsoBibItem::BibItemType]
    attr_reader :type

    # @return [Array<IsoBibItem::DocumentIdentifier>]
    attr_reader :docidentifier

    # @return [Array<IsoBibItem::BibliographicDate>]
    attr_reader :dates

    # @return [Array<IsoBibItem::ContributionInfo>]
    attr_reader :contributors

    # @return [String]
    attr_reader :edition

    # @return [Array<IsoBibItem::FormattedString>]
    attr_reader :notes

    # @return [Array<String>] language Iso639 code
    attr_reader :language

    # @return [Array<String>] script Iso15924 code
    attr_reader :script

    # @return [IsoBibItem::FormattedString]
    attr_reader :formatted_ref

    # @!attribute [r] abstract
    #   @return [Arra<IsoBibItem::FormattedString>]

    # @return [IsoBibItem::DocumentStatus]
    attr_reader :status

    # @return [IsoBibItem::CopyrightAssociation]
    attr_reader :copyright

    # @return [IsoBibItem::DocRelationCollection]
    attr_reader :relations

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param id [Arrat<IsoBibItem::DocumentIdentifier>]
    # @param title [Array<IsoBibItem::FormattedString>]
    # @param language [Arra<String>]
    # @param script [Array<String>]
    # @param dates [Array<Hash{type=>String, from=>String, to=>String}>]
    # @param contributors [Array<Hash{entity=>Hash{name=>String, url=>String,
    #   abbreviation=>String}, roles=>Array<String>}>]
    # @param abstract [Array<Hash{content=>String, language=>String,
    #   script=>String, type=>String}>]
    # @param relations [Array<Hash{type=>String, identifier=>String}>]
    def initialize(**args)
      @id            = args[:id]
      @title         = (args[:titles] || []).map { |t| FormattedString.new t }
      @docidentifier = []
      @dates         = (args[:dates] || []).map do |d|
        d.is_a?(Hash) ? BibliographicDate.new(d) : d
      end
      @contributors = (args[:contributors] || []).map do |c|
        e = c[:entity].is_a?(Hash) ? Organization.new(c[:entity]) : c[:entity]
        ContributionInfo.new(entity: e, role: c[:roles])
      end
      @notes         = []
      @language      = args[:language]
      @script        = args[:script]
      @abstract      = (args[:abstract] || []).map do |a|
        FormattedString.new(a)
      end
      @relations = DocRelationCollection.new(args[:relations] || [])
      @link = args[:link].map { |s| TypedUri.new(s) }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param lang [String] language code Iso639
    # @return [IsoBibItem::FormattedString, Array<IsoBibItem::FormattedString>]
    def abstract(lang: nil)
      if lang
        @abstract.find { |a| a.language.include? lang }
      else
        @abstract
      end
    end

    # @return [String]
    def to_xml
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.bibitem(id: id) do
          title.each { |t| xml.title { t.to_xml xml } }
          link.each { |s| s.to_xml xml }
          dates.each { |d| d.to_xml xml }
          contributors.each do |c|
            xml.contributor do
              c.role.each { |r| r.to_xml xml }
              c.to_xml xml
            end
          end
          language.each { |l| xml.language l }
        end
      end.doc.root.to_xml
    end
  end
end
