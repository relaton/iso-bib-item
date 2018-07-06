require 'nokogiri'
module IsoBibItem
  class << self
    def from_xml(doc)
      xml = Nokogiri::XML(doc)
      IsoBibliographicItem.new(
=begin
        docid:        fetch_docid(doc),
        edition:      edition,
        language:     langs(doc).map { |l| l[:lang] },
        script:       langs(doc).map { |l| script(l[:lang]) }.uniq,
        titles:       titles,
        type:         fetch_type(hit_data['title']),
        docstatus:    fetch_status(doc, hit_data['status']),
        ics:          fetch_ics(doc),
        dates:        fetch_dates(doc),
        contributors: fetch_contributors(hit_data['title']),
        workgroup:    fetch_workgroup(doc),
        abstract:     abstract,
        copyright:    fetch_copyright(hit_data['title'], doc),
        link:       fetch_link(doc, url),
        relations:    fetch_relations(doc)
=end
      )
    end
  end
end
