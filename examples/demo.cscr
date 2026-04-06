// ChronoScript Demo Program
// Comprehensive demonstration of language features

#Incorporate <timeline.h>
#Constant MAX_SIZE 100
#Constant PI 314159

// Global variables
Matter globalCounter = 0;

//Structure definition
structure Point {
    Energy x;
    Energy y;
};

structure Circle {
    Energy radius;
    Point center;
};

// Function: Calculate factorial recursively
Matter factorial(Matter n) {
    Era (n <= 1) {
        Resolve 1;
    }
    Resolve n * factorial(n - 1);
}

// Function: Check if number is prime
Matter isPrime(Matter num) {
    Era (num <= 1) {
        Resolve 0;
    }
    Era (num == 2) {
        Resolve 1;
    }
    
    Loop (Matter i = 2; i * i <= num; i = i + 1) {
        Era (num % i == 0) {
            Resolve 0;
        }
    }
    Resolve 1;
}

// Function: Calculate Fibonacci number
Matter fibonacci(Matter n) {
    Era (n <= 1) {
        Resolve n;
    }
    Resolve fibonacci(n - 1) + fibonacci(n - 2);
}

// Function: Find maximum in array
Matter findMax(Matter arr[], Matter size) {
    Era (size <= 0) {
        Resolve 0;
    }
    
    Matter max = arr[0];
    Loop (Matter i = 1; i < size; i = i + 1) {
        Era (arr[i] > max) {
            max = arr[i];
        }
    }
    Resolve max;
}

// Function: Calculate circle area
Energy calculateCircleArea(Energy radius) {
    Energy pi = 3.14159;
    Resolve pi * radius * radius;
}

// Function: Calculate distance between two points
Energy calculateDistance(Energy x1, Energy y1, Energy x2, Energy y2) {
    Energy dx = x2 - x1;
    Energy dy = y2 - y1;
    Energy distSquared = dx * dx + dy * dy;
    Resolve squareroot(distSquared);
}

// Main event function
Event main() {
    // Variable declarations
    Matter age = 25;
    Energy temperature = 98.6;
    Atom grade = 'A';
    Stream name = "ChronoScript";
    Truth isActive = 1;
    
    // Array declaration
    Matter numbers[10];
    Energy coordinates[3];
    
    // Initialize array
    Loop (Matter i = 0; i < 10; i = i + 1) {
        numbers[i] = i * i;
    }
    
    // Arithmetic operations
    Matter sum = 10 + 20;
    Matter difference = 50 - 15;
    Matter product = 6 * 7;
    Matter quotient = 100 / 5;
    Matter remainder = 17 % 5;
    
    // Bitwise operations
    Matter bitwiseAnd = 12 & 5;
    Matter bitwiseOr = 12 | 5;
    Matter bitwiseXor = 12 ^ 5;
    Matter leftShift = 3 << 2;
    Matter rightShift = 16 >> 2;
    
    // Logical operations
    Truth condition1 = (age > 18) && (age < 65);
    Truth condition2 = (temperature > 100.0) || (temperature < 32.0);
    Truth condition3 = !isActive;
    
    // Conditional statements
    Era (age >= 18) {
        Broadcast("Adult");
    } Alternate {
        Broadcast("Minor");
    }
    
    // Nested conditionals
    Era (temperature > 100.0) {
        Broadcast("Too hot!");
    } Alternate Era (temperature < 32.0) {
        Broadcast("Too cold!");
    } Alternate {
        Broadcast("Just right!");
    }
    
    // Loop with break and continue
    Loop (Matter i = 0; i < 10; i = i + 1) {
        Era (i == 5) {
            Persist;  // Skip 5
        }
        Era (i == 8) {
            Escape;   // Break at 8
        }
        Broadcast("Loop iteration");
    }
    
    // While-style loop
    Matter counter = 0;
    Loop (counter < 5) {
        counter = counter + 1;
        Broadcast("Counting...");
    }
    
    // Function calls
    Matter fact5 = factorial(5);
    Broadcast("Factorial of 5: ");
    
    Matter prime = isPrime(17);
    Era (prime == 1) {
        Broadcast("17 is prime");
    }
    
    Matter fib7 = fibonacci(7);
    Broadcast("7th Fibonacci number calculated");
    
    // Array operations
    Matter maximum = findMax(numbers, 10);
    Broadcast("Maximum value found");
    
    // Math functions
    Energy angle = 45.0;
    Energy sineValue = sine(angle);
    Energy cosineValue = cosine(angle);
    Energy tangentValue = tangent(angle);
    
    Energy sqrtValue = squareroot(16.0);
    Matter absValue = absolute(-42);
    Energy floorValue = floor(3.7);
    Energy ceilValue = ceiling(3.2);
    
    Energy logValue = logarithm(10.0);
    Energy powerValue = power(2.0, 8.0);
    
    // Circle calculations
    Energy radius = 5.0;
    Energy area = calculateCircleArea(radius);
    
    // Distance calculation
    Energy dist = calculateDistance(0.0, 0.0, 3.0, 4.0);
    
    // Complex expression
    Matter result = (10 + 5) * 3 - 8 / 2;
    
    // Compound assignment (if supported)
    sum = sum + 10;
    product = product * 2;
    
    // Final output
    Broadcast("ChronoScript Demo Completed Successfully!");
    
    Resolve 0;
}
