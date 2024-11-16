import pygame
import math
import time

# Initialize the pygame library
pygame.init()

# Set the size of the window and create the screen
WIDTH, HEIGHT = 800, 800
WIN = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Rotating Square Simulation")

# Define color constants
WHITE = (255, 255, 255)
YELLOW = (255, 255, 0)
DARK_GREY = (80, 78, 81)
LIGHT_BLUE = (173, 216, 230)
BLACK = (0, 0, 0)

# Set up font for displaying text
FONT = pygame.font.SysFont("comicsans", 20)

class Planet:
    AU = 149.6e6 * 1000  # Astronomical Unit in meters
    G = 6.67428e-11      # Gravitational constant
    SCALE = 250 / AU      # Scale for simulation (1 AU = 100 pixels)
    TIMESTEP = 3600 * 24  # Time step for each update (1 day in seconds)

    def __init__(self, x, y, size, color, mass):
        self.x = x
        self.y = y
        self.size = size  # Size of the square representing the planet
        self.color = color
        self.mass = mass

        self.orbit = []  # Store tuples of (x, y, timestamp)
        self.sun = False
        self.distance_to_sun = 0

        self.x_vel = 0
        self.y_vel = 0

    def draw(self, win):
        x = self.x * self.SCALE + WIDTH / 2
        y = self.y * self.SCALE + HEIGHT / 2

        # Draw the orbit path with fading effect
        current_time = time.time()
        faded_orbit = [(px, py) for px, py, timestamp in self.orbit if current_time - timestamp <= 2]

        if len(faded_orbit) > 2:
            updated_points = [
                (point[0] * self.SCALE + WIDTH / 2, point[1] * self.SCALE + HEIGHT / 2)
                for point in faded_orbit
            ]
            pygame.draw.lines(win, WHITE, False, updated_points, 2)

        # Draw the planet itself
        pygame.draw.circle(win, self.color, (int(x), int(y)), self.size)

    def attraction(self, other):
        other_x, other_y = other.x, other.y
        distance_x = other_x - self.x
        distance_y = other_y - self.y
        distance = math.sqrt(distance_x ** 2 + distance_y ** 2)

        if other.sun:
            self.distance_to_sun = distance

        force = self.G * self.mass * other.mass / distance**2
        theta = math.atan2(distance_y, distance_x)
        force_x = math.cos(theta) * force
        force_y = math.sin(theta) * force

        return force_x, force_y

    def update_position(self, planets, angular_velocity):
        total_fx = total_fy = 0

        for planet in planets:
            if self == planet:
                continue
            fx, fy = self.attraction(planet)
            total_fx += fx
            total_fy += fy

        # Update velocity from gravitational forces
        self.x_vel += total_fx / self.mass * self.TIMESTEP
        self.y_vel += total_fy / self.mass * self.TIMESTEP

        # Update position based on angular velocity for constant 10-second rotation
        theta = math.atan2(self.y, self.x) + angular_velocity * self.TIMESTEP
        radius = self.distance_to_sun

        self.x = radius * math.cos(theta)
        self.y = radius * math.sin(theta)

        # Add position to orbit with timestamp
        self.orbit.append((self.x, self.y, time.time()))


def main():
    run = True
    clock = pygame.time.Clock()

    # Create the Sun and Mercury
    sun = Planet(0, 0, 30, YELLOW, 1.98892 * 10**30)
    sun.sun = True

    mercury = Planet(0.387 * Planet.AU, 0, 8, DARK_GREY, 3.30 * 10**23)
    mercury.y_vel = -47.4 * 1000

    planets = [sun, mercury]

    # Angular velocity for 1 full rotation in 10 seconds
    angular_velocity = 2 * math.pi / (10 * 60 * 60 * 24)  # radians per second in simulation time

    while run:
        clock.tick(60)
        WIN.fill(BLACK)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False

        for planet in planets:
            if not planet.sun:
                planet.update_position(planets, angular_velocity)
            planet.draw(WIN)

        pygame.display.update()

    pygame.quit()


# Start the simulation
main()
