require 'mechanize'

bot = Mechanize.new
bot.follow_meta_refresh = true 
bot.verify_mode = OpenSSL::SSL::VERIFY_NONE
news = {}

id = bot.get("http://iitkgp.ac.in/").search(".description a")[0]["href"].gsub("shownews.php?newsid=","").to_i
while id > 0 do
  crawl_url = "http://iitkgp.ac.in/shownews.php?newsid="+id.to_s
  page = bot.get(crawl_url).search("td")
  head , desc = page[0].text.strip , page[1].text.strip.gsub("\r","").gsub("\n","")
  unless head.empty?
    news[head] = desc
    puts "Post #"+$news.count.to_s+" : "+$news[head]
  end
  id = id - 1
end