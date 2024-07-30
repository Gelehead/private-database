import pygame
import sys
from PIL import Image

def open_image(filepath):
    # Open the PPM image file using PIL
    img = Image.open(filepath)
    
    # Convert the image to RGB format if necessary
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Get image dimensions
    width, height = img.size
    
    # Initialize Pygame
    pygame.init()
    
    # Create a Pygame surface
    screen = pygame.display.set_mode((width, height))
    pygame.display.set_caption("PPM Image Display")
    
    # Load the image data into Pygame
    raw_data = img.tobytes()
    image = pygame.image.fromstring(raw_data, (width, height), 'RGB')
    
    # Display the image
    screen.blit(image, (0, 0))
    pygame.display.flip()
    
    # Main loop to keep the window open
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

    pygame.quit()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        open_image(sys.argv[1])
    else:
        print("Usage: python script.py <path_to_ppm_file>")
