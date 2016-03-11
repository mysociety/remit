require "net/http"
require "json"

class DoiNumberValidator < ActiveModel::Validator
  def validate(record)
    return if record.doi_number.blank?
    result = lookup_doi(record.doi_number)
    if result.blank?
      message = "we couldn't find that DOI number, can you check it " \
                "for typos? If everything's correct you might have to put " \
                "the details in manually."
      record.errors.add(:doi_number, message)
      return
    end
    record.article_title = result[:article_title]
    record.lead_author = result[:lead_author]
    record.book_or_journal_title = result[:book_or_journal_title]
    record.publication_year = result[:publication_year]
    if record.article_title.blank? ||
       record.lead_author.blank? ||
       record.book_or_journal_title.blank? ||
       record.publication_year.blank?
      message = "it doesn't look like we could get everything we " \
                "need from the DOI number. Can you fill in the missing pieces?"
      record.errors.add(:doi_number, message)
    end
  end

  def lookup_doi(doi)
    url = "http://api.crossref.org/works/#{doi}"
    uri = URI(url)
    begin
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)["message"]
      title = nil
      if result["title"].present?
        title = result["title"].first
      end
      journal = nil
      if result["publisher"].present?
        journal = result["publisher"]
      end
      author = nil
      if result["author"].present?
        result_author = result["author"].first
        if result_author.present?
          author = "#{result_author['family']}, #{result_author['given']}"
        end
      end
      year = nil
      if result["issued"].present? &&
         result["issued"]["date-parts"].present?
        year = result["issued"]["date-parts"].first.first
      end
      return {
        book_or_journal_title: journal,
        article_title: title,
        lead_author: author,
        publication_year: year
      }
    rescue
      # Return nothing
      Rails.logger.error($!.backtrace)
      return nil
    end
  end
end
