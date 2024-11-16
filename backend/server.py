from flask import Flask, request, jsonify

app = Flask(__name__)

# Initial spacecraft data
spacecraft_data = {
    "position": [0.0, 0.0, 0.0],  # X, Y, Z
    "angle": [0.0, 0.0, 0.0],     # Pitch, Yaw, Roll
    "velocity": [0.0, 0.0, 0.0]   # VX, VY, VZ
}

@app.route('/')
def home():
    """
    Endpoint for the root URL.
    """
    return jsonify({
        "message": "Welcome to the Spacecraft Communication API!",
        "endpoints": {
            "/get": "GET current spacecraft data",
            "/update": "POST to update spacecraft data"
        }
    }), 200

@app.route('/update', methods=['POST'])
def update_data():
    """
    Endpoint to update spacecraft data.
    Request body example:
    {
        "position": [1.0, 2.0, 3.0],
        "angle": [10.0, 20.0, 30.0],
        "velocity": [5.0, 5.0, 5.0]
    }
    """
    data = request.json
    if not data:
        return jsonify({"error": "No data provided"}), 400

    for key in ['position', 'angle', 'velocity']:
        if key in data:
            spacecraft_data[key] = data[key]

    return jsonify({"message": "Spacecraft data updated successfully", "data": spacecraft_data}), 200

@app.route('/get', methods=['GET'])
def get_data():
    """
    Endpoint to retrieve the current spacecraft data.
    """
    return jsonify(spacecraft_data), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
