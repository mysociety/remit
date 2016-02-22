require "biburi"

class DoiNumberValidator < ActiveModel::Validator
  def validate(record)
    return if record.doi_number.blank?
    result = BibURI.lookup(record.doi_number)
    if result.blank?
      message = "we couldn't find that DOI number, can you check it " \
                "for typos? If everything's correct you might have to put " \
                "the details in manually."
      record.errors.add(:doi_number, message)
      return
    end
    record.article_title = result.title.to_s
    record.lead_author = result.author.to_s
    record.book_or_journal_title = result.journal.to_s
    record.publication_year = result.year.to_s
    if record.article_title.blank? ||
       record.lead_author.blank? ||
       record.book_or_journal_title.blank? ||
       record.publication_year.blank?
      message = "it doesn't look like we could get everything we " \
                "need from the DOI number. Can you fill in the missing pieces?"
      record.errors.add(:doi_number, message)
    end
  end
end
