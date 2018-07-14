require 'nokogiri'

module IsoBibItem
  class << self
    def from_xml(xml)
      doc = Nokogiri::XML(xml)
      IsoBibliographicItem.new(
        docid:        fetch_docid(doc),
        edition:      doc.at('//bibiten/edition')&.text,
        language:     doc.xpath('//bibitem/language').map(&:text),
        script:       doc.xpath('//bibitem/script').map(&:text),
        titles:       fetch_titles(doc),
        type:         doc.at('//bibitem')[:type],
        docstatus:    fetch_status(doc),
        ics:          fetch_ics(doc),
        dates:        fetch_dates(doc),
        contributors: fetch_contributors(doc),
        workgroup:    fetch_workgroup(doc),
        abstract:     fetch_abstract(doc),
        copyright:    fetch_copyright(doc),
        link:         fetch_link(doc),
        relations:    fetch_relations(doc)
      )
    end

    private

    def fetch_docid(doc)
      did = doc.at('//bibitem/docidentifier')
      return unless did
      id = did.text.match(/(?<project>\d+)(?<hyphen>-)?(?(<hyphen>)(?<part>\d*))/)
      IsoBibItem::IsoDocumentId.new project_number: id[:project],
                                    part_number:    id[:part]
    end

    def fetch_titles(doc)
      doc.xpath('//bibitem/title').map do |t|
        titl = t.text.split ' -- '
        case titl.size
        when 0
          intro, main, part = nil, "", nil
        when 1
          intro, main, part = nil, titl[0], nil
        when 2
          if /^(Part|Partie) \d+:/.match? titles[1]
            intro, main, part = nil, titl[0], titles[1]
          else
            intro, main, part = titl[0], titl[1], nil
          end
        when 3
          intro, main, part = titl[0], titl[1], titl[2]
        else
          intro, main, part = titl[0], titl[1], titl[2..-1]&.join(" -- ")
        end
        IsoLocalizedTitle.new(title_intro: intro, title_main: main,
                              title_part: part, language: t[:language],
                              script: t[:script])
      end
    end

    def fetch_status(doc)
      status    = doc.at('//bibitem/status')
      stage     = status.at('//stage')&.text
      substage  = status.at('//substage')&.text
      iteration = status.at('//iterarion')&.text&.to_i
      IsoDocumentStatus.new(status: status&.text, stage: stage,
                            substage: substage, iteration: iteration)
    end

    def fetch_ics(doc)
      doc.xpath('//bibitem/ics/code').map { |ics| Ics.new ics.text }
    end

    def fetch_dates(doc)
      doc.xpath('//bibitem/date').map do |d|
        BibliographicDate.new(type: d[:type], on: d.at('//on')&.text,
                              from: d.at('//from')&.text,
                              to: d.at('//to')&.text)
      end
    end

    def fetch_contributors(doc)
      doc.xpath('//bibitem/contributor').map do |c|
        org = Organization.new(name: c.at('//name')&.text,
                               abbreviation: c.at('//abbreviation')&.text,
                               url: c.at('//uri')&.text)
        ContributionInfo.new entity: org, role: [c.at('//role')[:type]]
      end
    end

    # @TODO Organization doesn't recreated
    def fetch_workgroup(doc)
      eg = doc.at('//bibitem/editorialgroup')
      tc = eg.at('//technical_committee')
      sc = eg.at('//subcommittee')
      scom = sc && iso_subgroup(cs)
      wg   = eg.at('//workgroup')
      wgrp = wg && iso_subgroup(wg)
      IsoProjectGroup.new(technical_committee: iso_subgroup(tc),
                          subcommittee: scom, workgroup: wgrp)
    end

    def iso_subgroup(com)
      IsoSubgroup.new(name: com.text, type: com[:type],
                      number: com[:number].to_i)
    end

    def fetch_abstract(doc)
      doc.xpath('//bibitem/abstract').map do |a|
        FormattedString.new(content: a.text, language: a[:language],
                            script: a[:script], type: a[:format])
      end
    end

    def fetch_copyright(doc)
      cp     = doc.at('//bibitem/copyright')
      org    = cp.at('//owner/organization')
      name   = org.at('//name').text
      abbr   = org.at('//abbreviation').text
      url    = org.at('//uri').text
      entity = Organization.new(name: name, abbreviation: abbr, url: url)
      from   = cp.at('//from').text
      to     = cp.at('//to')&.text
      owner  = ContributionInfo.new entity: entity
      CopyrightAssociation.new(owner: owner, from: from, to: to)
    end

    def fetch_link(doc)
      doc.xpath('//bibitem/uri').map do |l|
        TypedUri.new type: l[:type], content: l.text
      end
    end

    def fetch_relations(doc)
      doc.xpath('//bibitem/relation').map do |r|
        DocumentRelation.new(type: r[:type],
                             identifier: r.at('//formattedref').text)
      end
    end
  end
end
