import os
import ccxt
import json


#COINBASE_SYMBOLS = ["BTC-USD", "ETH-USD", "ETC-USD", "MANA-USD", "VET-USD", "NEAR-USD", "VARA-USD", "MKR-USD", "GRT-USD", "NMR-USD", "MATIC-USD", "BCH-USD", "ALGO-USD", "ATOM-USD", "CAD-USD", "AURORA-USD"]
COINBASE_SYMBOLS = ["BTC-USD", "ETH-USD", "ETC-USD", "NEAR-USD", "MKR-USD", "NMR-USD", "BCH-USD", "ALGO-USD", "CAD-USD"]

script_dir = os.path.dirname(os.path.abspath(__file__))
file_dir =  script_dir + "\\register\\data.json"


def add_coinbase_transaction(transaction):
    """Format a Coinbase transaction for the audit file."""
    transaction_date = str(transaction['datetime'])
    exchange = "Coinbase"
    transaction_id = transaction['id']
    symbol = transaction['symbol'].replace("/", "-")
    side = transaction['side'].upper()
    amount = float(transaction['amount'])
    price = float(transaction['price'])
    fee = 0.0 if transaction['fee']['cost'] == None else float(transaction['fee']['cost'])
    sell_side_amount = float(transaction['amount'])
    return {"transaction_id": transaction_id, "transaction_date": transaction_date,"symbol": symbol, "amount": amount,"exchange": exchange,"price": price, "side": side, "sell_side_amount": sell_side_amount, "fee": fee}


def populate_coinbase(trades, symbol, comma):
    """Populate the audit file with Coinbase transactions for a given symbol."""

    if comma and COINBASE_SYMBOLS.index(symbol) < len(COINBASE_SYMBOLS) and COINBASE_SYMBOLS.index(symbol) > 0:
        with open(file_dir, "a") as audit_file: audit_file.write(',\n')

    for index, order in enumerate(trades):
        transaction = add_coinbase_transaction(order)
        with open(file_dir, "a") as audit_file:
            json.dump(transaction, audit_file)
            if index < len(trades) - 1:
                audit_file.write(',\n') 


def all_trades():
    client = ccxt.coinbase({'apiKey': '82ebf545-84bf-4da8-90fd-d5904fbbfa11'})#, 'secret': COINBASE_PRIVATE_KEY})
    with open(file_dir, "a") as audit_file: audit_file.write('{"transactions":[')
    comma = True
    for symbol in COINBASE_SYMBOLS:
        try:
            trades = client.fetch_trades(symbol)
            populate_coinbase(trades, symbol, comma)
            if COINBASE_SYMBOLS.index(symbol) > 0: comma = True
 
        except:                                             # Case where there are no trades for a product
            if COINBASE_SYMBOLS.index(symbol) == 0: comma = False   #if it is the first symbol, second symbol should not write comma at the begining of populate_coinbase()
            continue

    register_dir = os.path.join(script_dir, 'register')
    if not os.path.exists(register_dir): os.makedirs(register_dir)

    with open(file_dir, "a") as audit_file: audit_file.write(']}')


all_trades()