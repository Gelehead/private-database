import requests
from bs4 import BeautifulSoup
import pandas as pd
from cmath import log10

# Utility functions 
def get3digitFormat(num):
    return f"{num:03d}"

def text_to_image_link(text):
    return text.replace(" ", "%20")

# ACTUAL DATA GETTERS
def get_content(p_soup):
    """ transforms effect description from a card to understandable text

    Args:
        p_soup (String): HTML p container with text and possibly images

    Returns:
        String: readable effect description
    """
    text_parts = []

    for content in p_soup.contents:
        if content.name == 'img':
            text_parts.append(dices_adapter(content['title']))
        else:
            text_parts.append(content.strip())
    return ' '.join(text_parts)

def dices_adapter(dice):
    str(dice).replace(" ", "")
    match dice :
        case "diceb":
            return "defense die"


# TODO : automatic page making
def make_web_page(card_data):
    a=1

# note : this has been made in summer 2024, the game may have had some extensions since then ( if yes, add "extension" column )
def allCards(writeAllInFile=False):
    cards = []
    for i in range(1, 270):
        cards.append(singleCard("https://oathcards.seiyria.com/card/OATH-" + get3digitFormat(i) + "?q=&d=images&s=name&b=asc&p=0"))
    df = pd.DataFrame(cards, columns=['Title', 'Faction', 'Type', 'Effect', 'FAQ text', 'image'])

def singleCard(url, writeInFile=False):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    print(soup)
    
    data = []
    title = soup.find('h1').get_text()
    image = 'https://ledercardcdn.seiyria.com/cards/oath/en-US/' + text_to_image_link(title) + '.webp'
    effect = get_content(soup.find('app-card-text').find('p'))
    
    # create simple web page layout for the cards 
    if writeInFile:
        f = open(title + ".html", "w")
        f.write(make_web_page(data))
        
    return data

allCards()