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

    def hash2locstr(name)
      name.is_a?(Hash) ? LocalizedString.new(name[:content], name[:language], name[:script]) : LocalizedString.new(name)
    end

    # @param name [String]
    # @param abbreviation [String]
    # @param url [String]
    # @TODO identifier
    def initialize(name:, abbreviation: nil, url: nil, identifiers: [])
      super(url: url)
      @name = name.is_a?(Array) ? name.map { |n| hash2locstr(n) } : [hash2locstr(name)]
      @abbreviation = LocalizedString.new abbreviation
      @identifiers  = identifiers
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.organization do
        name.each do |n|
          builder.name { |b| n.to_xml b }
        end
        builder.abbreviation { |a| abbreviation.to_xml a } if abbreviation&.to_s
        builder.uri uri.to_s if uri
        identifiers.each { |identifier| identifier.to_xml builder }
        super
      end
    end
  end
end
