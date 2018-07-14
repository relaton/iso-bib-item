# frozen_string_literal: true

require 'iso_bib_item/contributor'

module IsoBibItem
  # module OrgIdentifierType
  #   ORCID = 'orcid'
  #   URI   = 'uri'
  # end

  # Organization identifier.
  class OrgIdentifier
    # @return [String]
    attr_reader :type

    # @return [String]
    attr_reader :value

    # @param type [String]
    # @param value [String]
    def initialize(type, value)
      @type  = type
      @value = value
    end

    def to_xml(builder)
      builder.identifier(value, type: type)
    end
  end

  # Organization.
  class Organization < Contributor
    # @return [IsoBibItem::LocalizedString]
    attr_reader :name

    # @return [IsoBibItem::LocalizedString]
    attr_reader :abbreviation

    # @return [Array<IsoBibItem::OrgIdentifier>]
    attr_reader :identifiers

    # @param name [String]
    # @param abbreviation [String]
    # @param url [String]
    # @TODO identifier
    def initialize(name:, abbreviation: nil, url: nil)
      super(url: url)
      @name         = LocalizedString.new name
      @abbreviation = LocalizedString.new abbreviation
      @identifiers  = []
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.organization do
        builder.name { |b| name.to_xml b }
        # unless abbreviati.content.nil? || abbreviation.content.empty?
        builder.abbreviation { |a| abbreviation.to_xml a }
        # end
        builder.uri uri.to_s if uri
        identifiers.each { |identifier| identifier.to_xml builder }
        super
      end
    end
  end
end
