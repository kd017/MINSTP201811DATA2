from splinter import Browser
from bs4 import BeautifulSoup as bs
import time
from pprint import pprint
import pandas as pd


def init_browser():
    # @NOTE: Replace the path with your actual path to the chromedriver
    executable_path = {"executable_path": "chromedriver"}
    return Browser("chrome", **executable_path, headless=False)

def scrape_news(browser):
    NASA_MARS_NEWS_URL = "https://mars.nasa.gov/news/"
    NASA_MARS_BASE_URL = "https://mars.nasa.gov"

    browser.visit(NASA_MARS_NEWS_URL)
    time.sleep(2)

    news_html = browser.html
    news_soup = bs(news_html, "html.parser")

    news_slide = news_soup.find("li", class_="slide")
    news_href = NASA_MARS_BASE_URL + news_slide.find('a')['href']
    news_title = news_slide.find("div", class_="content_title").text
    news_p = news_slide.find("div", class_="article_teaser_body").text
    return (news_title, news_href, news_p)

def scrape_featured_image(browser):
    JPL_SPACE_IMAGES_URL = "https://www.jpl.nasa.gov/spaceimages/?search=&category=Mars"
    JPL_BASE_URL = "https://www.jpl.nasa.gov"

    browser.visit(JPL_SPACE_IMAGES_URL)
    time.sleep(.5)
    jpl_html = browser.html

    jpl_soup = bs(jpl_html, "html.parser")

    carousel_content = jpl_soup.find("div", class_="carousel_container")
    nav_to_featured_image_link = JPL_BASE_URL + carousel_content.find("a", class_="fancybox")['data-link']

    browser.visit(nav_to_featured_image_link)
    time.sleep(.5)
    image_page_html = browser.html

    image_soup = bs(image_page_html, "html.parser")
    featured_image_url = JPL_BASE_URL + image_soup.find("img", class_="main_image")['src']
    return featured_image_url

def scrape_weather(browser):
    MARS_WEATHER_TWITTER_URL = "https://twitter.com/marswxreport?lang=en"

    browser.visit(MARS_WEATHER_TWITTER_URL)
    time.sleep(.5)
    weather_html = browser.html

    weather_soup = bs(weather_html, "html.parser")
    all_tweets = weather_soup.find_all("div", "tweet")
    for tweet in all_tweets:
        fullname = tweet.find("strong", "fullname").text
        if fullname != "Mars Weather":
            continue
        mars_weather = tweet.find("p", class_="tweet-text").text
        mars_weather = mars_weather.split("pic.")[0]
        return mars_weather

def scrape_facts():
    MARS_FACTS_URL = "http://space-facts.com/mars/"

    facts_tables = pd.read_html(MARS_FACTS_URL)
    mars_profile_df = facts_tables[0]
    mars_profile_df.columns =["Fact", "Value"]
    mars_profile_html = mars_profile_df.to_html(index=False)
    mars_profile_html = mars_profile_html.replace("dataframe", "table table-sm")
    mars_profile_html = mars_profile_html.replace('border="1"', '')
    return mars_profile_html

def scrape_hemispheres(browser):
    USGS_MARS_HEMISPHERES_URL = "https://astrogeology.usgs.gov/search/results?q=hemisphere+enhanced&k1=target&v1=Mars"
    USGS_BASE_URL = "https://astrogeology.usgs.gov"

    browser.visit(USGS_MARS_HEMISPHERES_URL)
    time.sleep(.5)
    usgs_html = browser.html

    usgs_soup = bs(usgs_html, "html.parser")
    all_hs_desc = usgs_soup.find_all("div", class_="description")
    all_hs_urls = []
    for desc in all_hs_desc:
        anchor = desc.find("a", class_="product-item")
        all_hs_urls.append(USGS_BASE_URL + anchor['href'])
    
    hemisphere_image_urls = []
    for hs_url in all_hs_urls:
        browser.visit(hs_url)
        time.sleep(.5)
        hs_html = browser.html
        hs_soup = bs(hs_html, "html.parser")
        download_section = hs_soup.find("div", class_="downloads")
        hs_url = download_section.find("a")['href']
        hs_title = hs_soup.find("h2", class_="title").text
        hs_info = {"title":hs_title, "img_url":hs_url}
        hemisphere_image_urls.append(hs_info)
    return hemisphere_image_urls

def scrape_info():
    # Initialize Browser
    browser = init_browser()

    # Scrape Mars News
    (news_title, news_href, news_p) = scrape_news(browser)

    # Scrape Featured Image
    featured_image_url = scrape_featured_image(browser)

    # Scrape Weather
    mars_weather = scrape_weather(browser)

    # Scrape Facts
    mars_profile_html = scrape_facts()

    # Scrape Mars Hemispheres
    hemisphere_image_urls = scrape_hemispheres(browser)

    # Quit the browser after scraping
    browser.quit()

    # Compose Results Dictionary
    mars_data = {}

    mars_data['news_title'] = news_title
    mars_data['news_href'] = news_href
    mars_data['news_p'] = news_p
    mars_data['featured_image_url'] = featured_image_url
    mars_data['mars_weather'] = mars_weather
    mars_data['mars_profile_html'] = mars_profile_html
    mars_data['hemisphere_image_urls'] = hemisphere_image_urls

    pprint(mars_data)

    # Return results
    return mars_data

if __name__ == '__main__':
    scrape_info()