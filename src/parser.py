import re
import csv
import math

# dicionario para guardar informacao relativamente aos pontos de recolha
#                             lista dos contentores    pares     impares 
# "morada" : (idpr, freguesia, [(idtipo,quantidade)], [morada], [morada]) 
pontos_recolha = dict()

def arcos(nr, info):
    with open("arcos.pl", "a+") as file:
        for node in info[nr]:
            if node not in pontos_recolha.keys():
                print(node , " não é um ponto de recolha")
            else: 
                node_info = pontos_recolha[node]
                if(nr == 3): arco = "arco(" + info[0] + "," + node_info[0] + "," + dist(float(info[5]), float(info[6]), float(node_info[5]), float(node_info[6])) + ").\n"
                else : arco = "arco(" + node_info[0] + "," + info[0] + "," + dist(float(info[5]), float(info[6]), float(node_info[5]), float(node_info[6])) + ").\n"
                file.write(arco)
                arco = ""
    file.close()

def rad(coordenada):
    return coordenada*math.pi/180

def dist(lat1, long1, lat2, long2):
    r = 6378.137 
    dlat = rad(lat2 - lat1)
    dlong = rad(long2 - long1)
    a = pow(math.sin(dlat/2),2) + math.cos(rad(lat1)) * math.cos(rad(lat2)) * pow(math.sin(dlong/2), 2)
    c = 2* math.atan2(math.sqrt(a), math.sqrt(1-a))
    d = r * c * 1000 
    return "{0:.2f}".format(d)

def buildDataset():
    with open("pontos_recolha.pl", "w+") as f:
        for morada,info in pontos_recolha.items():
            #print(morada)
            str = "ponto_recolha(" + info[0] + ",'" + morada + "','" + info[1] + "',["
            for index, contentor in enumerate(info[2], start=0):
                if index == len(info[2]) - 1:
                    str += "('" + contentor[0] + "'," + contentor[1] + "," + contentor[2] + ")]).\n"
                else:
                    str += "('" + contentor[0] + "'," + contentor[1] + "," + contentor[2] + "),"
            f.write(str)
            str = ""

            #arcos(3, info)
            #arcos(4, info)
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
        paridade = localinfo.group(4); origem = "".join(localinfo.group(5).rstrip()); destino = "".join(localinfo.group(6).rstrip())

    if localinfo.group(2) in pontos_recolha:
        [_,_, contentores, lo, ld,_,_] = pontos_recolha[localinfo.group(2)]
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
        print("adding " , morada, " to dict")
        pontos_recolha[localinfo.group(2)] = [idpr,freguesia, [[c_tipo, c_capacidade, c_quantidade]], [origem], [destino], latitude, longitude]

    if paridade == "Ambos": #a: b-c temos nodo b-a e a-c falta c-a e a-b
        [_,_,_,lo,ld,_,_] = pontos_recolha[localinfo.group(2)]
        if origem not in ld: ld.append(origem)
        if destino not in lo: lo.append(destino)


with open('dataset.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        buildInfo(row)

#print(pontos_recolha)
buildDataset()