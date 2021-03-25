require 'open-uri'

url = 'https://www.scrapmaker.com/data/wordlists/twelve-dicts/5desk.txt'
remote_data = open(url).read
local_file = open('5dest.txt', 'w')
local_file.write(remote_data)
local_file.close