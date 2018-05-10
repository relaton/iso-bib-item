require 'iso_bib_item/contributor'

module IsoBibItem
  # Person's full name
  class FullName
    # @return [Array<IsoBibItem::LocalizedString>]
    attr_accessor :forenames

    # @return [Array<IsoBibItem::LocalizedString]
    attr_accessor :inials

    # @return [IsoBibItem::LocalizedString]
    attr_accessor :surname

    # @return [Array<IsoBibItem::LocalizedString]
    attr_accessor :additions

    # @return [Array<IsoBibItem::LocalizedString]
    attr_accessor :prefix

    def initialize(surname)
      @surname   = surname
      @forenames = []
      @initials  = []
      @additions = []
      @prefix    = []
    end
  end

  module PersonIdentifierType
    ISNI = 'isni'.freeze
    URI  = 'uri'.freeze
  end

  # Person identifier.
  class PersonIdentifier
    # @return [PersonIdentifierType]
    attr_accessor :type

    # @return [String]
    attr_accessor :value

    def initialize(type, value)
      @type  = type
      @value = value
    end
  end

  # Person class.
  class Person < Contributor
    # @return [IsoBibItem::FullName]
    attr_accessor :name

    # @return [Array<IsoBibItem::Affilation>]
    attr_accessor :affilation

    # @return [Array<IsoBibItem::PersonIdentifier>]
    attr_accessor :identifiers

    def initialize
      super
      @affilation = []
      @identifiers = []
    end
  end
end
