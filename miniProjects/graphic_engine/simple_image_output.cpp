#include <iostream>
#include <string>

int main() {
    // Image dimensions
    int image_width = 1024;
    int image_height = 1024;

    // Render the PPM header
    std::cout << "P3\n" << image_width << ' ' << image_height << "\n1024\n";

    // Write the RGB value of each pixel for each row and column
    for (int j = 0; j < image_height; j++) { 
        std::clog << "\rScanlines remaining: " << (image_height - j) << ' ' << std::flush; 
        
        for (int i = 0; i < image_width; i++) {
            auto r = double(i) / (image_width - 1);
            auto g = double(j) / (image_height - 1);
            auto b = 0.25;

            int ir = static_cast<int>(255.999 * r);
            int ig = static_cast<int>(255.999 * g);
            int ib = static_cast<int>(255.999 * b);

            // Print each RGB value with proper spacing
            std::cout << ir << ' ' << ig << ' ' << ib << ' ';
        }
        std::cout << '\n'; // Ensure a newline after each row
    }

    std::clog << "\rDone                  \n";
    return 0;
}
