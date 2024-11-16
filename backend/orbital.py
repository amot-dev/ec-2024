import pygame
import math

# Initialize the pygame library
pygame.init()

# Set the size of the window and create the screen
WIDTH, HEIGHT = 800, 800
WIN = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Single Planet Simulation")  # Update window title

# Define color constants
WHITE = (255, 255, 255)
YELLOW = (255, 255, 0)
DARK_GREY = (80, 78, 81)

# Set up font for displaying text
FONT = pygame.font.SysFont("comicsans", 16)

class Planet:
    AU = 149.6e6 * 1000  # Astronomical Unit in meters
    G = 6.67428e-11      # Gravitational constant
    SCALE = 250 / AU      # Scale for simulation (1 AU = 100 pixels)
    TIMESTEP = 3600 * 24  # Time step for each update (1 day in seconds)

    def __init__(self, x, y, radius, color, mass):
        self.x = x
        self.y = y
        self.radius = radius
        self.color = color
        self.mass = mass

        self.orbit = []
        self.sun = False
        self.distance_to_sun = 0

        self.x_vel = 0
        self.y_vel = 0

    def draw(self, win):
        x = self.x * self.SCALE + WIDTH / 2
        y = self.y * self.SCALE + HEIGHT / 2

        # Draw the orbit path in white
        if len(self.orbit) > 2:
            updated_points = [
                (point[0] * self.SCALE + WIDTH / 2, point[1] * self.SCALE + HEIGHT / 2)
                for point in self.orbit
            ]
            pygame.draw.lines(win, WHITE, False, updated_points, 2)

        # Draw the planet itself
        pygame.draw.circle(win, self.color, (int(x), int(y)), self.radius)

        # Display distance to the sun
        if not self.sun:
            distance_text = FONT.render(f"{round(self.distance_to_sun/1000, 1)}km", 1, WHITE)
            win.blit(distance_text, (x - distance_text.get_width()/2, y - distance_text.get_height()/2))

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

    def update_position(self, planets, thrust=0):
        total_fx = total_fy = 0

        for planet in planets:
            if self == planet:
                continue
            fx, fy = self.attraction(planet)
            total_fx += fx
            total_fy += fy

        # Modify velocity directly based on thrust
        tangential_thrust = thrust * 10  # Scale thrust to a meaningful range
        self.x_vel += tangential_thrust * (-self.y / self.distance_to_sun)
        self.y_vel += tangential_thrust * (self.x / self.distance_to_sun)

        # Update velocities based on gravitational forces
        self.x_vel += total_fx / self.mass * self.TIMESTEP
        self.y_vel += total_fy / self.mass * self.TIMESTEP

        # Update position based on velocities
        self.x += self.x_vel * self.TIMESTEP
        self.y += self.y_vel * self.TIMESTEP

        self.orbit.append((self.x, self.y))


def main():
    run = True
    clock = pygame.time.Clock()

    # Create the Sun and Mercury
    sun = Planet(0, 0, 30, YELLOW, 1.98892 * 10**30)
    sun.sun = True

    mercury = Planet(0.387 * Planet.AU, 0, 8, DARK_GREY, 3.30 * 10**23)
    mercury.y_vel = -47.4 * 1000

    planets = [sun, mercury]
    thrust = 0

    while run:
        clock.tick(60)
        WIN.fill((0, 0, 0))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT:  # Decrease thrust
                    thrust = max(-100, thrust - 10)
                elif event.key == pygame.K_RIGHT:  # Increase thrust
                    thrust = min(100, thrust + 10)

        for planet in planets:
            if not planet.sun:
                planet.update_position(planets, thrust)
            planet.draw(WIN)

        # Display current thrust value
        thrust_text = FONT.render(f"Thrust: {thrust}", 1, WHITE)
        WIN.blit(thrust_text, (10, 10))

        pygame.display.update()

    pygame.quit()


# Start the simulation
main()
