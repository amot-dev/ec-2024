from flask import Flask, request, jsonify
import threading
import time
import math

app = Flask(__name__)

# Constants for the simulation
TIME_STEP = 0.1  # Time step for simulation updates (seconds)

class Planet:
    AU = 149.6e6 * 1000  # Astronomical Unit in meters
    G = 6.67428e-11      # Gravitational constant
    TIMESTEP = TIME_STEP  # Time step for the simulation

    def __init__(self, x, y, size, color, mass):
        self.x = x
        self.y = y
        self.size = size
        self.color = color
        self.mass = mass
        self.orbit = []
        self.sun = False
        self.distance_to_sun = 0
        self.x_vel = 0.0
        self.y_vel = 0.0
        self.angle = 0.0  # Orientation angle of the spacecraft

    def attraction(self, other):
        """
        Calculate the gravitational force between this object and another.
        """
        distance_x = other.x - self.x
        distance_y = other.y - self.y
        distance = math.sqrt(distance_x**2 + distance_y**2)

        if other.sun:
            self.distance_to_sun = distance

        force = self.G * self.mass * other.mass / (distance**2)
        theta = math.atan2(distance_y, distance_x)
        force_x = math.cos(theta) * force
        force_y = math.sin(theta) * force

        return force_x, force_y

    def update_position(self, planets, thrust=0, thrust_speed=50):
        """
        Update the position of the planet based on gravitational forces and thrust.
        """
        total_fx = total_fy = 0.0

        # Calculate gravitational forces
        for planet in planets:
            if self == planet:
                continue
            fx, fy = self.attraction(planet)
            total_fx += fx
            total_fy += fy

        # Apply thrust in the direction of the spacecraft's orientation
        if thrust == 1:
            self.x_vel += math.cos(self.angle + math.pi / 2) * thrust_speed
            self.y_vel += math.sin(self.angle + math.pi / 2) * thrust_speed

        # Update velocities based on gravitational forces
        self.x_vel += total_fx / self.mass * self.TIMESTEP
        self.y_vel += total_fy / self.mass * self.TIMESTEP

        # Update position based on velocities
        self.x += self.x_vel * self.TIMESTEP
        self.y += self.y_vel * self.TIMESTEP

        # Update orbit for visualization or tracking
        self.orbit.append((self.x, self.y))


# Create Earth (central body) and spacecraft
earth = Planet(0, 0, 30, (255, 255, 0), 5.972 * 10**24)  # Earth
earth.sun = True

spacecraft = Planet(300.0, 0.0, 8, (100, 149, 237), 1000.0)  # Spacecraft
spacecraft.y_vel = 30.0  # Initial velocity to simulate orbital motion

# List of celestial objects
planets = [earth, spacecraft]

# Lock for thread-safe updates
state_lock = threading.Lock()

# Variables to control thrust
thrust = 0
thrust_speed = 50


def update_simulation():
    """
    Continuously updates the spacecraft's position and velocity.
    """
    global thrust, thrust_speed
    while True:
        with state_lock:
            spacecraft.update_position(planets, thrust, thrust_speed)
        time.sleep(TIME_STEP)


@app.route('/get', methods=['GET'])
def get_state():
    """
    Returns the current state of the spacecraft.
    """
    with state_lock:
        orbital_velocity = math.sqrt(spacecraft.x_vel**2 + spacecraft.y_vel**2)
        return jsonify({
            "position": {"x": spacecraft.x, "y": spacecraft.y},
            "rotation": spacecraft.angle,
            "velocity": {"x": spacecraft.x_vel, "y": spacecraft.y_vel},
            "orbital_velocity": orbital_velocity,
            "distance_to_earth": spacecraft.distance_to_sun
        })


@app.route('/set_rotation', methods=['POST'])
def set_rotation():
    """
    Sets the spacecraft's rotation angle.
    """
    data = request.json
    if "rotation" in data:
        with state_lock:
            spacecraft.angle = math.radians(data["rotation"])
        return jsonify({"status": "success", "rotation": data["rotation"]})
    return jsonify({"status": "error", "message": "Rotation value missing"}), 400


@app.route('/set_thrust', methods=['POST'])
def set_thrust():
    """
    Sets the spacecraft's thrust level.
    """
    data = request.json
    if "thrust" in data:
        with state_lock:
            # Clamp thrust to 0 or 1
            global thrust
            thrust = max(0, min(1, data["thrust"]))
        return jsonify({"status": "success", "thrust": thrust})
    return jsonify({"status": "error", "message": "Thrust value missing"}), 400


if __name__ == "__main__":
    # Start the simulation in a background thread
    simulation_thread = threading.Thread(target=update_simulation, daemon=True)
    simulation_thread.start()

    # Start the Flask server
    app.run(host="0.0.0.0", port=5000, debug=True)
