from flask import Flask, request, jsonify
from orbit import Planet  # Import your Planet class
import threading

app = Flask(__name__)

# Create the Earth and Spacecraft as Planet objects
earth = Body(0, 0, 30, (255, 255, 0), 5.972 * 10**24)  # Earth
earth.sun = True  # Earth acts as the central gravitational body

spacecraft = Body(0.387 * Body.AU, 0, 8, (100, 149, 237), 500)  # Spacecraft
spacecraft.y_vel = 29.783 * 1000  # Initial velocity for orbital motion

# List of all celestial objects
planets = [earth, spacecraft]

# Thrust and angle values to be updated via Flask
thrust = 0
thrust_speed = 50


@app.route('/update', methods=['POST'])
def update():
    """
    Update the thrust and angle for the spacecraft.
    """
    global thrust

    data = request.get_json()

    if "angle" in data:
        try:
            # Update spacecraft's angle in radians
            spacecraft.angle = float(data["angle"])
        except ValueError:
            return jsonify({"error": "Invalid angle value"}), 400

    if "thrust" in data:
        try:
            # Update spacecraft's angle in radians
            spacecraft.thrust = float(data["thrust"])
        except ValueError:
            return jsonify({"error": "Invalid angle value"}), 400

    return jsonify({"message": "Update successful"})


@app.route('/get', methods=['GET'])
def get_data():
    """
    Get the current spacecraft data.
    """
    return jsonify({
        "angle": spacecraft.angle,
        "x": spacecraft.x,
        "y": spacecraft.y,
        "x_vel": spacecraft.x_vel,
        "y_vel": spacecraft.y_vel,
        "distance_to_earth": spacecraft.distance_to_sun
    })


def simulation_loop():
    """
    Continuous simulation loop to update the spacecraft's position.
    """
    global thrust, thrust_speed

    while True:
        spacecraft.update_position(planets, thrust, thrust_speed)


if __name__ == '__main__':
    # Run the simulation loop in a separate thread
    simulation_thread = threading.Thread(target=simulation_loop, daemon=True)
    simulation_thread.start()
    app.run(host='0.0.0.0', port=5000, debug=True)
