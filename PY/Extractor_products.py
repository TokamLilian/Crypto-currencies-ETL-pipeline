import os
import json
import ccxt


COINBASE_SYMBOLS = ["BTC-USD", "ETH-USD", "ETC-USD", "USDT-USD", "BTC-USDT", "ETH-USDT", "SHIB-USD", "BTC-EUR", "ETH-EUR", "USDT-EUR", "BTC-GBP", "ETH-GBP", "NEAR-USD", "MKR-USD", "NMR-USD", "BCH-USD", "ALGO-USD", "USDC-EUR", "USDT-EUR"]

script_dir = os.path.dirname(os.path.abspath(__file__))
products_dir =  script_dir + "\\register\\products.json"


def public_products():
    #client = ccxt.coinbase({'apiKey': COINBASE_PUBLIC_KEY, 'secret': COINBASE_PRIVATE_KEY})
    products = {}
    try:
        #products = client.fetch_markets()

        import http.client
        conn = http.client.HTTPSConnection("api.coinbase.com")
        payload = ''
        headers = {
        'Content-Type': 'application/json'
        }
        conn.request("GET", "/api/v3/brokerage/market/products", payload, headers)
        res = conn.getresponse()
        data = res.read()
        return json.loads(data.decode("utf-8"))
    except:
        pass#;raise Exception
    return products


def populate(products):
    array = []
    #for key in products:
    for key in products["products"]:
        #if key['info']['product_id'] in COINBASE_SYMBOLS:
        if key['product_id'] in COINBASE_SYMBOLS:
            #array.append(key['info'])
            array.append(key)
    return array


# get products on coinbase
def get_products():
    products = public_products()
    products_data = {}
    products_array = populate(products)
    products_data["products"] = products_array
    products_data["num_products"] = len(products_array)
    
    register_dir = os.path.join(script_dir, 'register')
    if not os.path.exists(register_dir): os.makedirs(register_dir)
        
    with open(products_dir, "w") as product_file:
        json.dump(products_data, product_file)


get_products()