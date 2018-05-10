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
      builder.source(content.to_s, type: type)
    end
  end

  # Bibliographic item
  class BibliographicItem
    # @return [Array<IsoBibItem::FormattedString>]
    attr_reader :title

    # @return [Array<IsoBibItem::TypedUri>]
    attr_reader :source

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

    # @param language [Arra<String>]
    # @param script [Array<String>]
    # @param dates [Array<Hash{type=>String, from=>String, to=>String}>]
    # @param contributors [Array<Hash{entity=>Hash{name=>String, url=>String,
    #   abbreviation=>String}, roles=>Array<String>}>]
    # @param abstract [Array<Hash{content=>String, language=>String,
    #   script=>String, type=>String}>]
    # @param relations [Array<Hash{type=>String, identifier=>String}>]
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def initialize(**args)
      @title         = []
      @docidentifier = []
      @dates         = (args[:dates] || []).map { |d| BibliographicDate.new(d) }
      @contributors  = (args[:contributors] || []).map do |c|
        ContributionInfo.new(entity: Organization.new(c[:entity]),
                             role:   c[:roles])
      end
      @notes         = []
      @language      = args[:language]
      @script        = args[:script]
      @abstract      = (args[:abstract] || []).map do |a|
        FormattedString.new(a)
      end
      @relations = DocRelationCollection.new(args[:relations] || [])
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # @param docid [DocumentIdentifier]
    # def add_docidentifier(docid)
    #   @docidentifier << docid
    # end

    # @param lang [String] language code Iso639
    # @return [IsoBibItem::FormattedString, Array<IsoBibItem::FormattedString>]
    def abstract(lang: nil)
      if lang
        @abstract.find { |a| a.language.include? lang }
      else
        @abstract
      end
    end
  end
end
