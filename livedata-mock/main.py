from flask import Flask, jsonify
import threading
import time

app = Flask(__name__)

data = {"NSE:NIFTY BANK": {"instrument_token": 260105, "last_price": 48493.05}}  # Initial JSON object

# Function to update the JSON data in a while loop
def update_data():
    while True:
        data["NSE:NIFTY BANK"]['last_price'] += 1
        time.sleep(1)  # Wait for 1 second before updating again

# Start the thread to update data
update_thread = threading.Thread(target=update_data)
update_thread.start()

# Route to get the JSON data
@app.route('/data')
def get_data():
    return str(data["NSE:NIFTY BANK"]['last_price'])

# Start the Flask app
if __name__ == '__main__':
    app.run(debug=True)


