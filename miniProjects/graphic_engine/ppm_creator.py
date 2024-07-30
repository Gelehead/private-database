width = 512
height = 512

with open('out/gradient.ppm', 'w') as f:
    f.write("P3\n")
    f.write(str(width) + " " + str(height) + "\n")
    f.write("511\n")
    
    for y in range(height):
        for x in range(width):
            r = x
            g = y
            b = (x + y) // 2
            f.write(f"{r} {g} {b} ")
        f.write("\n")
