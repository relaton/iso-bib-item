# frozen_string_literal: true

require 'iso_bib_item/localized_string'

module IsoBibItem
  # Dovument status.
  class DocumentStatus
    # @return [IsoBibItem::LocalizedString]
    attr_reader :status

    # @param status [IsoBibItem::LocalizedString]
    def initialize(status)
      @status = status
    end

    # @param [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.status do
        # FormattedString.instance_method(:to_xml).bind(status).call builder
        status.to_xml builder
      end
    end
  end
end
