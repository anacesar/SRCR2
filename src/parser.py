import re
import csv

# dicionario para guardar informacao relativamente aos pontos de recolha
#                             lista dos contentores    pares     impares 
# "morada" : (idpr, freguesia, [(idtipo,quantidade)], [morada], [morada]) 
pontos_recolha = dict()

def buildDataset():
    with open("pontos_recolha.csv", "w+") as f:
        for morada,info in pontos_recolha.items():
            print(morada)
            str = "pontos_recolha('" + info[0] + "','" + morada + ",["
            print(info[2])
            for index, contentor in enumerate(info[2], start=0):
                if index == len(info[2]) - 1:
                    str += "('" + contentor[0] + "','" + contentor[1] + "','" + contentor[2] + "')]\n"
                else:
                    str += "('" + contentor[0] + "','" + contentor[1] + "','" + contentor[2] + "'),"
            f.write(str)
            str = ""

    f.close()

def buildInfo(info):
    #info = row.split("\n")[0].split(",")

    # ponto de recolha info 
    latitude = info['Latitude']; longitude = info['Longitude']; freguesia = info['PONTO_RECOLHA_FREGUESIA']; local = info['PONTO_RECOLHA_LOCAL']
    c_tipo = info['CONTENTOR_RESÍDUO']; c_id_tipo = info['CONTENTOR_TIPO']; c_capacidade = info['CONTENTOR_CAPACIDADE']
    c_quantidade = info['CONTENTOR_QT']; c_total_litros = info['CONTENTOR_TOTAL_LITROS']

    localinfo = re.search(r'([\d]+): ([\w ]+)(\(([\w]*)[^\:]*: ([\w ]*) \- ([\w ]*)\))?' ,local)
    # group [1]-idpr  [2]-morada  [4]-paridade  [5]-origem  [6]-destino
    idpr = localinfo.group(1); morada = localinfo.group(2); paridade = ""; origem = ""; destino = "" 
    if localinfo.group(3): 
        paridade = localinfo.group(4); origem = localinfo.group(5); destino = localinfo.group(6)

    if localinfo.group(2) in pontos_recolha:
        [_,_, contentores, lo, ld] = pontos_recolha[localinfo.group(2)]
        exist = False
        for c in contentores:
            tipo = c[0]; capacidade = c[1]; quantidade = c[2]
            if tipo == c_tipo and capacidade == c_capacidade: 
                c[2] = str(int(quantidade) + int(c_quantidade))
                exist = True
                break
        if not exist: 
            contentores.append([c_tipo, c_capacidade, c_quantidade])
        if origem not in lo: lo.append(origem)
        if destino not in ld: ld.append(destino)
    else: 
        pontos_recolha[localinfo.group(2)] = [idpr,freguesia, [[c_tipo, c_capacidade, c_quantidade]], [origem], [destino]]

    if paridade == "Ambos": #a: b-c temos nodo b-a e a-c falta c-a e a-b
        [_,_,_,lo,ld] = pontos_recolha[localinfo.group(2)]
        if origem not in ld: ld.append(origem)
        if destino not in lo: lo.append(destino)

'''
with open('tinydataset.csv', 'r') as f:
    #f.readline() #to read first line 
    
    for line in f: 
        buildInfo(line)

    #buildDataset()
    print(pontos_recolha)'''

with open('tinydataset.csv', newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        buildInfo(row)

#print(pontos_recolha)
buildDataset()