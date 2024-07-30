import tkinter as tk
from PIL import ImageGrab, ImageTk

def update_image():
    # Grab a screenshot of the screen
    screenshot = ImageGrab.grab()
    
    # Convert the screenshot to a PhotoImage object
    photo = ImageTk.PhotoImage(screenshot)
    
    # Update the Label widget with the new image
    img_label.config(image=photo)
    img_label.image = photo
    
    # Schedule the function to run again after 100 milliseconds
    root.after(60, update_image)

# Create the main window
root = tk.Tk()
root.title("Live Screen Display")

# Create a Label widget to hold the screenshot image
img_label = tk.Label(root)
img_label.pack()

# Start the update process
update_image()

# Start the Tkinter event loop
root.mainloop()
