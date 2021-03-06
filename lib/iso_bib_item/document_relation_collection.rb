# frozen_string_literal: true

module IsoBibItem
  # module DocumentRelationType
  #   PARENT        = 'parent'
  #   CHILD         = 'child'
  #   OBSOLETES     = 'obsoletes'
  #   UPDATES       = 'updates'
  #   COMPLEMENTS   = 'complements'
  #   DERIVED_FORM  = 'derivedForm'
  #   ADOPTED_FORM  = 'adoptedForm'
  #   EQUIVALENT    = 'equivalent'
  #   IDENTICAL     = 'identical'
  #   NONEQUIVALENT = 'nonequivalent'
  # end

  # class SpecificLocalityType
  #   SECTION   = 'section'
  #   CLAUSE    = 'clause'
  #   PART      = 'part'
  #   PARAGRAPH = 'paragraph'
  #   CHAPTER   = 'chapter'
  #   PAGE      = 'page'
  #   WHOLE     = 'whole'
  #   TABLE     = 'table'
  #   ANNEX     = 'annex'
  #   FIGURE    = 'figure'
  #   NOTE      = 'note'
  #   EXAMPLE   = 'example'
  #   # generic String is allowed
  # end

  # Bibliographic item locality.
  class BibItemLocality
    # @return [IsoBibItem::SpecificLocalityType]
    attr_reader :type

    # @return [IsoBibItem::LocalizedString]
    attr_reader :reference_from

    # @return [IsoBibItem::LocalizedString]
    attr_reader :reference_to

    # @param type [String]
    # @param referenceFrom [IsoBibItem::LocalizedString]
    # @param referenceTo [IsoBibItem::LocalizedString]
    def initialize(type, reference_from, reference_to = nil)
      @type           = type
      @reference_from = reference_from
      @reference_to   = reference_to
    end

    def to_xml(builder)
      builder.locality(type: type) do
        builder.referenceFrom { reference_from.to_xml(builder) }
        builder.referenceTo reference_to if reference_to
      end
    end
  end

  # Documett relation
  class DocumentRelation
    # @return [String]
    attr_reader :type

    # @return [String]
    attr_reader :identifier, :url

    # @return [IsoBibItem::BibliographicItem]
    attr_reader :bibitem

    # @return [Array<IsoBibItem::BibItemLocality>]
    attr_reader :bib_locality

    # @param type [String]
    # @param identifier [String]
    def initialize(type:, identifier:, url: nil, bib_locality: [], bibitem: nil)
      type = "obsoletes" if type == "Now withdrawn"
      @type         = type
      @identifier   = identifier
      @url          = url
      @bib_locality = bib_locality
      @bibitem      = bibitem
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.relation(type: type) do
        if @bibitem.nil?
          builder.bibitem do
            builder.formattedref identifier
            # builder.docidentifier identifier
          end
          bib_locality.each do |l|
            l.to_xml builder
          end
        else
          @bibitem.to_xml(builder, {})
        end
        # builder.url url
      end
    end
  end

  # Document relations collection
  class DocRelationCollection < Array
    # @param [Array<Hash{type=>String, identifier=>String}>]
    def initialize(relations)
      super relations.map { |r| r.is_a?(Hash) ? DocumentRelation.new(r) : r }
    end

    # @return [Array<IsoBibItem::DocumentRelation>]
    def replaces
      select { |r| r.type == 'replace' }
    end
  end
end
