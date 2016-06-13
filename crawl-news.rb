require 'mechanize'
require 'json'

bot = Mechanize.new
bot.follow_meta_refresh = true 
bot.verify_mode = OpenSSL::SSL::VERIFY_NONE

news_list = (File.exists? "news.json") ? JSON.parse(File.read("news.json")) : [ ]
puts "#{news_list.length} news articles already exist."

id = bot.get("http://iitkgp.ac.in/").search(".description a")[0]["href"].gsub("shownews.php?newsid=","").to_i

start = (news_list.length > 0) ? news_list.last["id"].to_i + 1 : 1

for i in (start..id)
	crawl_url = "http://iitkgp.ac.in/shownews.php?newsid="+i.to_s
	page = bot.get(crawl_url).search("td")
	head , desc = page[0].text.strip , page[1].text.strip.gsub("\r","").gsub("\n","").encode("UTF-8", invalid: :replace, undef: :replace).gsub("\t","")
	unless head.empty?
		news = { "id" => i.to_s, "Headlines" => head, "Description" => desc }
		news_list.push(news)  
	end
	puts "Scraped news article #"+i.to_s
end

puts "#{news_list.length} news articles now."

File.delete("news.json") if File.exists? "news.json"

File.open("news.json", "a") { |file| file.write(JSON.generate(news_list)) }
