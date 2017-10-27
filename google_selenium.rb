require "selenium-webdriver"
require "test/unit"
require "byebug"

class Page
	def initialize(driver)
		@se = driver
	end

	def get_current_url
		@se.current_url
	end

	def go_back
		@se.navigate.back 
	end
end

class GoogleHome < Page
	attr_reader :locs

	def initialize(driver)
		super(driver)
		@wait = Selenium::WebDriver::Wait.new(:timeout => 5)
		@locs = {
			search_input: {css: 'input[name=q]'}, 
			search_button: {css: 'input.lsb'},
		}
	end

	def fill_search_term(search_term)
		@se.find_element(locs[:search_input]).send_keys(search_term)
	end

	def submit_search
		@wait.until { @se.find_element(locs[:search_button]) }
		@se.find_element(locs[:search_button]).click
	end

end

class GoogleSearchResults < Page
	attr_reader :locs
	
	def initialize(driver)
		super(driver)
		@wait = Selenium::WebDriver::Wait.new(:timeout => 5)
		@locs = {
			results_list: {css: '.srg'},
			results_item: {css: '.srg .rc'},
			result_header: {css: 'h3'},
			result_cite: {css: 'cite'},
		}
	end

	def wait_until_page_loads
		@wait.until { @se.find_element(@locs[:results_item]) }
	end

	# Get search results elements 
	#   Returns array of web elements - the paragraphs on the search results page
	def get_search_results
		wait_until_page_loads
		@se.find_elements(@locs[:results_item])
	end

	# click the link in a search result header  
	#   parameter result - web element, assumed to be a search result 
 	def click_result_header(result)
 		link = get_result_header_link(result)
 		begin
	 		link.click
	 	rescue Selenium::WebDriver::Error::UnknownError => e
	 		raise e if !e.message.include?("Element is not clickable")
	 		p=link.location_once_scrolled_into_view
	 		@se.execute_script("window.scrollTo(#{p.x},#{p.y})")
	 		link.click
	 	end
 	end

	# parameter result - web element, assumed to be a search result
	# returns the link in the header node
	def get_result_header_link(result)
		result.find_element(@locs[:result_header]).find_element({css: 'a'})
	end

	# parameter result - web element, assumed to be a search result
	# returns cite's text
	def get_result_cite_text(result)
		result.find_element(@locs[:result_cite]).text
	end

end

class GoogleTest < Test::Unit::TestCase

  def setup
	@se = Selenium::WebDriver.for :chrome
	@se.get('https://www.google.com')
  end

  def teardown
  	#@se.quite
  end

  def test_search_results_1
  	verify_search_results_page("buster keaton")
  end

  def test_search_results_2
  	verify_search_results_page("platypus")
  end

  def verify_search_results_page(search_term)

  	def strip_http(url)
  		return url[7..-1] if url.start_with?('http://')
  		return url[8..-1] if url.start_with?('https://')
  		return url
  	end

  	page = GoogleHome.new(@se)
  	page.fill_search_term(search_term)
  	page.submit_search

	# verify all results display the search term
	page = GoogleSearchResults.new(@se)
	search_term_regex = Regexp.new(search_term, Regexp::IGNORECASE)

	results = page.get_search_results
	results.each { |item| assert_match(search_term_regex, item.text) }

	result_count = results.size
	# verify link in header opens same page as 'cite' line
	(0...result_count).each { |idx|
		print "index #{idx} "
		results = page.get_search_results # need fresh page each iteration
		cite = strip_http(page.get_result_cite_text(results[idx]))

		page.click_result_header(results[idx])
		dest_page = Page.new(@se)
		dest_url = strip_http(dest_page.get_current_url)

		# verify destination url matches cite line
		if cite.include?('...')
			# cite replaced parts of URL with '...'.  Use regex with .*
			print "cite has ..."
			r = cite.gsub('...', '.+')
			cite_regex = Regexp.new(r, Regexp::IGNORECASE)
			assert_match(cite_regex, dest_url)
		elsif cite.include?(" › ")
			# cite is reformated to suggest a hierachy. Compare before "›"
			print "cite has › "
			cite_domain = cite.match(/(.*?) › /)[1]
			assert_equal(dest_url[0...cite_domain.length], cite_domain)
		elsif dest_url.include?("#")
			# ignore #fragment at end of destination url 
			print "dest has #"
			dest2 = dest_url.match(/(.*)#/)[1]
			assert_equal(dest2, cite)
		else
			# otherwise URLs are expected to match exactly  
			assert_equal(dest_url, cite)
		end
		puts ''

		dest_page.go_back
		page.wait_until_page_loads  # wait for results page
	}

	# Next:
	#  break search term into words.  verify all words are in search paragraph
	#  search "people also ask" if they contain any word in search term.
	#  search lines at bottom if they contain any word in search term.
	#  refactor to handle a list of search terms: buster keaton, earth, ...
	#    which have slightly modified formats.
	#  results time (top of page) is less than 1 second

  end

end
