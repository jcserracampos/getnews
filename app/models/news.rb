class News < ApplicationRecord
  def self.refresh
    url = 'https://news.google.com/'
    # Open Google News HTML
    doc = Nokogiri::HTML(RestClient.get(url))
    # Parse GN HTML
    results = doc.search('.section-content', '.blended-wrapper').map do |link|
      result = {}
      # Find Title
     result[:title] = link.search('div.esc-lead-article-title-wrapper > h2').text
      # Find description
      result[:description] = link.search('div.esc-lead-snippet-wrapper').text
      # Find link
      result[:link] = link.search('.esc-lead-article-title > a').attr('href').value
      # News date
      result[:time] = link.search('.al-attribution-timestamp').text
      result
    end
    # Clean old news
    News.all.delete_all
    # Create new news
    results.each_with_index do |n, i|
      next if i == 0
      News.create n
    end
  end
end
