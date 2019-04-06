# frozen_string_literal: true

require 'iso_bib_item/formatted_string'
require 'iso_bib_item/contribution_info'
require 'iso_bib_item/bibliographic_date'
require 'iso_bib_item/series'

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

    def initialize(id:, type:)
      @id   = id
      @type = type
    end

    #
    # Add docidentifier xml element
    #
    # @param [Nokogiri::XML::Builder] builder
    #
    def to_xml(builder)
      builder.docidentifier(id, type: type)
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
      @owner = if owner.is_a?(Hash)
                 ContributionInfo.new entity: Organization.new(owner)
               else owner end
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
      builder.uri(content.to_s, type: type)
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
    #   @return [Array<IsoBibItem::FormattedString>]

    # @return [IsoBibItem::DocumentStatus]
    attr_reader :status

    # @return [IsoBibItem::CopyrightAssociation]
    attr_reader :copyright

    # @return [IsoBibItem::DocRelationCollection]
    attr_reader :relations

    # @return [Array<IsoBibItem::Series>]
    attr_reader :series

    # @return [Date]
    attr_reader :fetched

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param id [String]
    # @param title [Array<IsoBibItem::FormattedString>]
    # @param docid [Array<IsoBibItem::DocumentIdentifier]
    # @param language [Arra<String>]
    # @param script [Array<String>]
    # @param docstatus [IsoBibItem::DocumentStatus, NilClass]
    # @param dates [Array<Hash{type=>String, from=>String, to=>String}>]
    # @param contributors [Array<Hash{entity=>Hash{name=>String, url=>String,
    #   abbreviation=>String}, roles=>Array<String>}>]
    # @param abstract [Array<Hash{content=>String, language=>String,
    #   script=>String, type=>String}>]
    # @param relations [Array<Hash{type=>String, identifier=>String}>]
    # @param series [Array<IsoBibItem::Series>]
    # @param fetched [Date] default today
    def initialize(**args)
      @id            = args[:id]
      @title         = (args[:titles] || []).map { |t| FormattedString.new t }
      @docidentifier = args[:docid] || []
      @dates         = (args[:dates] || []).map do |d|
        d.is_a?(Hash) ? BibliographicDate.new(d) : d
      end
      @contributors = (args[:contributors] || []).map do |c|
        if c.is_a? Hash
          e = c[:entity].is_a?(Hash) ? Organization.new(c[:entity]) : c[:entity]
          ContributionInfo.new(entity: e, role: c[:roles])
        else c
        end
      end
      @notes         = []
      @language      = args[:language]
      @script        = args[:script]
      @status        = args[:docstatus]
      @abstract      = (args[:abstract] || []).map do |a|
        a.is_a?(Hash) ? FormattedString.new(a) : a
      end
      @relations = DocRelationCollection.new(args[:relations] || [])
      @link = args[:link].map { |s| s.is_a?(Hash) ? TypedUri.new(s) : s }
      @series = args[:series]
      @fetched = args.fetch :fetched, Date.today
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

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

    # @return [String]
    def to_xml
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.bibitem(id: id) do
          xml.fetched fetched
          title.each { |t| xml.title { t.to_xml xml } }
          link.each { |s| s.to_xml xml }
          docidentifier.each { |di| di.to_xml xml }
          dates.each { |d| d.to_xml xml }
          contributors.each do |c|
            xml.contributor do
              c.role.each { |r| r.to_xml xml }
              c.to_xml xml
            end
          end
          language.each { |l| xml.language l }
          status&.to_xml xml
          relations.each { |r| r.to_xml xml }
          series.each { |s| s.to_xml xml } if series
        end
      end.doc.root.to_xml
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
