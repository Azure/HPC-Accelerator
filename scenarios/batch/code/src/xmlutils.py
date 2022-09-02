import pandas as pd
import numpy as np
import datetime as dt
import xml.etree.ElementTree as ET
import string
import random

# CDATA hack
def serialize_xml_with_CDATA(write, elem, qnames, namespaces, short_empty_elements, **kwargs):
    ET._original_serialize_xml = ET._serialize_xml
    if elem.tag == 'CDATA':
        write("<![CDATA[{}]]>".format(elem.text))
        return
    ET._serialize_xml = ET._serialize['xml'] = serialize_xml_with_CDATA
    return ET._original_serialize_xml(write, elem, qnames, namespaces, short_empty_elements, **kwargs)

def CDATA(text):
   element =  ET.Element("CDATA")
   element.text = text
   return element

# xml pretty printer
def indent(elem, level=0):
  i = "\n" + level*"  "
  if len(elem):
    if not elem.text or not elem.text.strip():
      elem.text = i + "  "
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
    for elem in elem:
      indent(elem, level+1)
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
  else:
    if level and (not elem.tail or not elem.tail.strip()):
      elem.tail = i

def id_generator(size=8, chars=string.ascii_uppercase + string.digits):
	return ''.join(random.choice(chars) for _ in range(size))

def GenerateTrade(tradenum,nbytes):
    # just use the time now
    today = dt.date.today()
    stoday = "%s" % (today)

    tradeformatted = "%010d" % tradenum

    root = ET.Element("AZFINSIMTRADE")
    trade = ET.SubElement(root, "AzFinsimSyntheticTradeData")
    trade.set("id",tradeformatted)
    trade.set("tradeType","SWAP")
    trade.set("process","iso")
    trade.set("location","Mars")
    trade.set("businessDate",stoday)

    #-- create random CDATA serial stream
    randbuf = ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(nbytes))
    #print randbuf
    #print random.getrandbits(1024)

    data = ET.SubElement(trade, "AdditionalData", type="azfinsim01")
    data.append(CDATA(randbuf))

    tdata = ET.SubElement(trade, "AdditionalData", type="azfinsim02")
    qldata = ET.SubElement(tdata, "QuantLib")
    assets = ET.SubElement(qldata, "Assets")
    stream = ET.SubElement(assets, "swapStream")
    swapStreamID = id_generator()
    stream.set("id",swapStreamID)

    formulae = ET.SubElement(stream, "FORMULAE", Asset_ProductName="FWDBOND")
    formula = ET.SubElement(formulae, "Formula", Asset_Formula_Date=stoday, Asset_Formula="FWDBOND US12345ORG89")

    indent(root)
    tree = ET.ElementTree(root)
    #tree.write('filename.xml', xml_declaration=True, encoding='utf-8', method="xml")
    xmlstring = ET.tostring(root, encoding="utf-8", method="xml")
    return(xmlstring)

def GenerateTradeEY(tradenum,N):
    # just use the time now
    today = dt.date.today()
    stoday = "%s" % (today)

    tradeformatted = "%010d" % tradenum
    newFile = {}
    newFile['fx1'] = np.random.rand(N)*0.12+0.8285

    newFile['start_date'] = [dt.date(2017,12,29)]*N
    newFile['end_date'] = [dt.date(2018,8,28)]*N

    newFile['drift'] = np.random.rand(N)*0.2 - 0.1
    newFile['maturity'] = [0.20]*N

    t_steps = np.busday_count(dt.date(2017,12,29), dt.date(2018,8,28) )# number of working days between 29/12/2017 and 08/03/2018
    newFile['t_steps']  = [t_steps]*N
    #-- 10k vs 100k Monte Carlo Paths
    #newFile['trials'] = np.random.randint(10000,10000,N)
    #newFile['trials'] = np.random.randint(100000,100000,N)
    newFile['trials'] = np.repeat(10000,N)  
    #newFile['trials'] = np.repeat(100000,N)

    newFile['ro'] = [0.000038413221829]*N # calibration value: 0.000038413221829   Vega01 value: 0.0000387714624899
    newFile['v'] = [0.00154807378604]*N
    newFile['sigma1'] = np.random.rand(N) * 0.03 - 0.015 +  0.0808844481978

    newFile['warrantsNo'] = np.random.randint(30000,60000,N)
    newFile['notionalPerWarr'] = np.random.rand(N)*100 + 950
    #newFile['strike'] = np.random.rand(N)*0.2 + 0.9
    newFile['strike'] = np.random.rand(N)*0.12 + 0.7
 
    newFile = pd.DataFrame.from_dict(newFile)
    #newFile.to_csv('XXXX.csv')

    #aroot = etree.Element('data');
    root = ET.Element("AZFINSIM")

    for i,row in newFile.iterrows():
        #print(row['fx1'],row['start_date'],row['drift'],row['maturity'],row['t_steps'],row['trials'])
        #print(row['ro'],row['v'],row['sigma1'],row['warrantsNo'],row['notionalPerWarr'],row['strike'])
        trade = ET.SubElement(root, "trade",
                              fx1 = "%.16f" % (row['fx1']), 
                              start_date = "%s" % (row['start_date']),
                              end_date = "%s" % (row['end_date']),
                              drift = "%2.17f" % (row['drift']),
                              maturity = "%.2f" % (row['maturity']),
                              t_steps = "%d" % (row["t_steps"]),
                              trials = "%d" % (row["trials"]),
                              ro = "%2.10e" % (row["ro"]),
                              v = "%2.16f" % (row["v"]),
                              sigma1 = "%2.17f" % (row["sigma1"]),
                              warrantsNo = "%d" % (row["warrantsNo"]),
                              notionalPerWarr = "%2.16f" % (row["notionalPerWarr"]),
                              strike = "%2.16f" % (row["strike"])
                             )
        trade.text = tradeformatted

    indent(root)
    #ET.dump(root);
    tree = ET.ElementTree(root)
    #tree.write('filename.xml', xml_declaration=True, encoding='utf-8', method="xml")
    xmlstring = ET.tostring(root, encoding="utf-8", method="xml")
    return(xmlstring)

def xml_to_dataframe(elem):
    fx1 = float(elem.get('fx1'))
    start_date = elem.get('start_date')
    end_date = elem.get('end_date')
    drift = float(elem.get('drift'))
    maturity = float(elem.get('maturity'))
    t_steps = int(elem.get('t_steps'))
    trials = int(elem.get('trials'))
    ro = float(elem.get('ro'))
    v = float(elem.get('v'))
    sigma1 = float(elem.get('sigma1'))
    warrantsNo = int(elem.get('warrantsNo'))
    notionalPerWarr = float(elem.get('notionalPerWarr'))
    strike = float(elem.get('strike'))
    trade = elem.text
    return fx1, start_date, end_date, drift, maturity, t_steps, trials, ro, v, sigma1, warrantsNo, notionalPerWarr, strike
    

def ParseEYXML(xmlstring):
    root = ET.fromstring(xmlstring)
    #tree = ET.parse('trade2.xml')
    #root = tree.getroot()
    trade_elements = root.iter('trade')
    #print(trade_elements)
    trade_data = pd.DataFrame(list(map(xml_to_dataframe, trade_elements)),
                              columns=['fx1','start_date','end_date','drift','maturity',
                                      't_steps','trials','ro','v','sigma1','warrantsNo','notionalPerWarr','strike'])
    #trade_data = list(map(xml_to_dataframe, trade_elements))
    #print("xml trade data:")
    #print(trade_data.to_string())
    #drift = trade_data.loc[0,'drift']
    #print(drift)
    return(trade_data)