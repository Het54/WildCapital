from flask import Flask, jsonify
import threading
import time

app = Flask(__name__)

data = {'value': 0}  # Initial JSON object

# Function to update the JSON data in a while loop
def update_data():
    while True:
        data['value'] += 1
        time.sleep(1)  # Wait for 1 second before updating again

# Start the thread to update data
update_thread = threading.Thread(target=update_data)
update_thread.start()

# Route to get the JSON data
@app.route('/data')
def get_data():
    return jsonify(data)

# Start the Flask app
if __name__ == '__main__':
    app.run(debug=True)


positionData = {
    "status": "success",
    "data": {
        "net": [
            {
                "tradingsymbol": "LEADMINI17DECFUT",
                "exchange": "MCX",
                "instrument_token": 53496327,
                "product": "NRML",
                "quantity": 1,
                "overnight_quantity": 0,
                "multiplier": 1000,
                "average_price": 161.05,
                "close_price": 0,
                "last_price": 161.05,
                "value": -161050,
                "pnl": 0,
                "m2m": 0,
                "unrealised": 0,
                "realised": 0,
                "buy_quantity": 1,
                "buy_price": 161.05,
                "buy_value": 161050,
                "buy_m2m": 161050,
                "sell_quantity": 0,
                "sell_price": 0,
                "sell_value": 0,
                "sell_m2m": 0,
                "day_buy_quantity": 1,
                "day_buy_price": 161.05,
                "day_buy_value": 161050,
                "day_sell_quantity": 0,
                "day_sell_price": 0,
                "day_sell_value": 0
            },
        ]
    }
}