# frozen_string_literal: true

require 'iso_bib_item/document_status'
require 'iso_bib_item/localized_string'

module IsoBibItem
  # module IsoDocumentStageCodes
  #   PREELIMINARY = '00'
  #   PROPOSAL     = '10'
  #   PREPARATORY  = '20'
  #   COMMITTE     = '30'
  #   ENQUIRY      = '40'
  #   APPROVAL     = '50'
  #   PUBLICATION  = '60'
  #   REVIEW       = '90'
  #   WITHDRAWAL   = '95'
  # end

  # module IsoDocumentSubstageCodes
  #   REGISTRATION              = '00'
  #   START_OF_MAIN_ACTION      = '20'
  #   COMPLETION_OF_MAIN_ACTION = '60'
  #   REPEAT_AN_EARLIER_PHASE   = '92'
  #   REPEAT_CURRENT_PHASE      = '92'
  #   ABADON                    = '98'
  #   PROCEED                   = '99'
  # end

  # ISO Document status.
  class IsoDocumentStatus < DocumentStatus
    # @return [String, NilClass]
    attr_reader :stage

    # @return [String, NilClass]
    attr_reader :substage

    # @return [Integer, NilClass]
    attr_reader :iteration

    # @param status [String, NilClass]
    # @param stage [String, NilClass]
    # @param substage [String, NilClass]
    # @param iteration [Integer, NilClass]
    def initialize(status: nil, stage: nil, substage: nil, iteration: nil)
      raise ArgumentError, 'status or stage is required' unless status || stage
      super LocalizedString.new(status)
      @stage     = stage
      @substage  = substage
      @iteration = iteration
    end

    # @param builder [Nkogiri::XML::Builder]
    def to_xml(builder)
      if stage.nil? || stage.empty?
        super
      else
        builder.status do
          builder.stage stage
          builder.substage substage if substage
          builder.iteration iteration if iteration
        end
      end
    end
  end
end
