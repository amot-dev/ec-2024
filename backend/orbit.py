import pygame
import math

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

class Button:
    def __init__(self, x, y, width, height, text, color=LIGHT_BLUE):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.text = text
        self.color = color

    def draw(self, win):
        pygame.draw.rect(win, self.color, (self.x, self.y, self.width, self.height))
        text = FONT.render(self.text, True, BLACK)
        win.blit(text, (self.x + (self.width - text.get_width()) // 2, self.y + (self.height - text.get_height()) // 2))

    def is_clicked(self, pos):
        return self.x <= pos[0] <= self.x + self.width and self.y <= pos[1] <= self.y + self.height


class Planet:
    AU = 149.6e6 * 1000  # Astronomical Unit in meters
    G = 6.67428e-11      # Gravitational constant
    SCALE = 250 / AU      # Scale for simulation (1 AU = 100 pixels)
    TIMESTEP = 600 * 24  # Time step for each update (1 day in seconds)

    def __init__(self, x, y, size, color, mass):
        self.x = x
        self.y = y
        self.size = size  # Size of the square representing the planet
        self.color = color
        self.mass = mass

        self.orbit = []
        self.sun = False
        self.distance_to_sun = 0

        self.x_vel = 0
        self.y_vel = 0
        self.angle = 0  # Initial orientation angle

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

        # Rotate the square around its center
        half_size = self.size // 2
        corners = [
            (-half_size, -half_size),
            (half_size, -half_size),
            (half_size, half_size),
            (-half_size, half_size)
        ]
        rotated_corners = []
        for corner in corners:
            rotated_x = corner[0] * math.cos(self.angle) - corner[1] * math.sin(self.angle)
            rotated_y = corner[0] * math.sin(self.angle) + corner[1] * math.cos(self.angle)
            rotated_corners.append((rotated_x + x, rotated_y + y))

        pygame.draw.polygon(win, self.color, rotated_corners)

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

    def update_position(self, planets, thrust=0, thrust_speed=50):
        total_fx = total_fy = 0

        for planet in planets:
            if self == planet:
                continue
            fx, fy = self.attraction(planet)
            total_fx += fx
            total_fy += fy

        # Apply thrust in the direction of the bottom side of the square
        if thrust == 1:
            self.x_vel += math.cos(self.angle + math.pi / 2) * thrust_speed
            self.y_vel += math.sin(self.angle + math.pi / 2) * thrust_speed

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

    # Create the Sun and Earth
    sun = Planet(0, 0, 30, YELLOW, 1.98892 * 10**30)
    sun.sun = True

    earth = Planet(0.387 * Planet.AU, 0, 8, DARK_GREY, 3.30 * 10**23)
    earth.y_vel = 29.783 * 1000 

    planets = [sun, earth]
    thrust = 0  # Initially no thrust
    thrust_speed = 50  # Reduced thrust speed to keep the planet visible
    angle_input = ""  # Input buffer for angle input

    while run:
        clock.tick(60)
        WIN.fill((0, 0, 0))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_RETURN and angle_input:
                    try:
                        # Update the angle based on input
                        earth.angle = math.radians(float(angle_input))
                        angle_input = ""  # Clear input buffer
                    except ValueError:
                        pass
                elif event.key == pygame.K_BACKSPACE:
                    angle_input = angle_input[:-1]
                elif event.unicode.isdigit() or event.unicode == ".":
                    angle_input += event.unicode
                elif event.key == pygame.K_SPACE:  # Toggle thrust
                    thrust = 1 if thrust == 0 else 0

        for planet in planets:
            if not planet.sun:
                planet.update_position(planets, thrust, thrust_speed)
            planet.draw(WIN)

        # Display thrust state and angle input
        thrust_text = FONT.render(f"Thrust: {'ON' if thrust else 'OFF'}", 1, WHITE)
        angle_text = FONT.render(f"Angle (deg): {math.degrees(earth.angle):.2f}", 1, WHITE)
        input_text = FONT.render(f"Input: {angle_input}", 1, WHITE)
        WIN.blit(thrust_text, (10, 10))
        WIN.blit(angle_text, (10, 40))
        WIN.blit(input_text, (10, 70))

        pygame.display.update()

    pygame.quit()


# Start the simulation
main()
