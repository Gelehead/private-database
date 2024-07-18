import requests
from bs4 import BeautifulSoup
import pandas as pd
from cmath import log10

# Utility functions 
def get3digitFormat(num):
    return f"{num:03d}"

# note : this has been made in summer 2024, the game may have had some extensions since then ( if yes, add "extension" column )
def allCard(writeAllInFile=False):
    cards = []
    for i in range(1, 270):
        cards.append(singleCard("https://oathcards.seiyria.com/card/OATH-" + get3digitFormat(i) + "?q=&d=images&s=name&b=asc&p=0"))
    df = pd.DataFrame(cards, columns=['Name', 'Faction', 'Type', 'Effect', 'FAQ text', 'image'])

def singleCard(url, writeInFile=False):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    data = []
    image = soup.find('ion-img').find('img').get('src')
    print(image)
    for row in soup.find('table').find('tbody').select('tr'):
        moveName = cell.find('td', class_='cell-name').find('a', class_='ent-name').get_text()
        moveType = cell.find('td', class_='cell-icon').find('a').get_text()
        moveCat = cell.find('td', class_='cell-icon text-center')['data-sort-value']
        movePower_Acc_PP_ProbofsecEffect = []
        for cellNum in cell.select('td.cell-num'):
            movePower_Acc_PP_ProbofsecEffect.append(cellNum.get_text())
        moveEff = cell.find('td', class_='cell-long-text')
        moves.append([moveName, moveType, moveCat,\
                      '-' if movePower_Acc_PP_ProbofsecEffect[0] == '—' else movePower_Acc_PP_ProbofsecEffect[0], \
                      '-' if movePower_Acc_PP_ProbofsecEffect[1] == '—' else movePower_Acc_PP_ProbofsecEffect[1], \
                      '-' if movePower_Acc_PP_ProbofsecEffect[2] == '—' else movePower_Acc_PP_ProbofsecEffect[3], \
                      moveEff, \
                      '-' if movePower_Acc_PP_ProbofsecEffect[3] == '—' else movePower_Acc_PP_ProbofsecEffect[3]])

    # did not get what the dataFrame is for
    df = pd.DataFrame(moves, columns=['Name', 'Type', 'Category', 'Power', 'Accuracy', 'PP', 'Effect', 'Prob of effect'])

    if writeInFile:
        df.to_csv("AllMoves.csv", index=False)
        
    return df