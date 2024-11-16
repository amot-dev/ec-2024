import threading
import math
import time
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Lock for thread-safe updates
state_lock = threading.Lock()

# Constants for the simulation
GRAVITATIONAL_CONSTANT = 500.0  # Gravitational constant
BODY_MASS = 5000.0  # Mass of the central body
TIME_STEP = 0.05  # Small time step for smooth updates (seconds)
TIME_DILATION = 1  # Time dilation factor (0.1 = 10x slower)

# Maximum thrust in terms of force (arbitrary units, modify as needed)
MAX_THRUST = 10.0  # Max possible thrust force the rocket can apply

# Rocket state
rocket = {
    "x": 400.0,  # Initial x position (just outside the planet's radius)
    "y": 0.0,  # Initial y position
    "vx": 0.0,  # Initial velocity in x
    "vy": 50.0,  # Initial velocity in y (orbit speed)
    "rotation": 0.0,  # Initial rotation angle (degrees, 0 is +x direction)
    "thrust_percent": 0.0,  # Thrust as a percentage (0-100) sent by client
}

def update_simulation():
    """Continuously updates the rocket's position and velocity."""
    while True:
        with state_lock:
            # Apply time dilation factor for slow motion
            effective_time_step = TIME_STEP * TIME_DILATION
            
            # Calculate distance and gravitational force
            distance = math.sqrt(rocket["x"] ** 2 + rocket["y"] ** 2)
            force_gravity = GRAVITATIONAL_CONSTANT * BODY_MASS / distance**2
            acceleration_gravity = force_gravity / 1.0  # Assume rocket mass = 1.0
            
            # Calculate gravitational acceleration components
            ax_gravity = -acceleration_gravity * (rocket["x"] / distance)
            ay_gravity = -acceleration_gravity * (rocket["y"] / distance)
            
            # Calculate thrust force based on percentage
            thrust_force = (rocket["thrust_percent"] / 100.0) * MAX_THRUST  # Thrust as a fraction of MAX_THRUST
            ax_thrust = thrust_force * math.cos(math.radians(rocket["rotation"]))
            ay_thrust = thrust_force * math.sin(math.radians(rocket["rotation"]))
            
            # Update velocity
            rocket["vx"] += (ax_gravity + ax_thrust) * effective_time_step
            rocket["vy"] += (ay_gravity + ay_thrust) * effective_time_step
            
            # Update position
            rocket["x"] += rocket["vx"] * effective_time_step
            rocket["y"] += rocket["vy"] * effective_time_step
        
        time.sleep(TIME_STEP)  # This controls the update frequency

@app.route('/get', methods=['GET'])
def get_state():
    """Returns the current state of the rocket."""
    with state_lock:
        # Calculate orbital velocity
        orbital_velocity = math.sqrt(rocket["vx"]**2 + rocket["vy"]**2)
        return jsonify({
            "position": {"x": rocket["x"], "y": rocket["y"]},
            "rotation": rocket["rotation"],
            "orbital_velocity": orbital_velocity,
            "thrust_percent": rocket["thrust_percent"]  # Return the thrust percentage
        })

@app.route('/set_rotation', methods=['POST'])
def set_rotation():
    """Sets the rocket's rotation."""
    data = request.json
    if "rotation" in data:
        with state_lock:
            rocket["rotation"] += data["rotation"]
        return jsonify({"status": "success", "rotation": rocket["rotation"]})
    return jsonify({"status": "error", "message": "Rotation value missing"}), 400

@app.route('/set_thrust', methods=['POST'])
def set_thrust():
    """Sets the rocket's thrust (percentage of maximum thrust)."""
    data = request.json
    if "thrust_percent" in data:
        with state_lock:
            # Ensure thrust percent is between 0 and 100
            rocket["thrust_percent"] = max(0, min(100, data["thrust_percent"]))
        return jsonify({"status": "success", "thrust_percent": rocket["thrust_percent"]})
    return jsonify({"status": "error", "message": "Thrust percentage missing"}), 400

if __name__ == "__main__":
    # Start the simulation in a background thread
    simulation_thread = threading.Thread(target=update_simulation, daemon=True)
    simulation_thread.start()

    # Start the Flask server
    app.run(host="0.0.0.0", port=5000)