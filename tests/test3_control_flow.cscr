// Test 3: Control Flow Structures
// Tests: if/else, while loops, for loops, break, continue

Event main() {
    Matter x = 10;
    Matter y = 20;
    Energy temp = 75.5;
    
    // Simple if statement
    Era (x < y) {
        Broadcast("x is less than y");
    }
    
    // If-else statement
    Era (temp > 100.0) {
        Broadcast("Too hot!");
    } Alternate {
        Broadcast("Temperature is OK");
    }
    
    // If-else-if chain
    Matter grade = 85;
    Era (grade >= 90) {
        Broadcast("Grade: A");
    } Alternate Era (grade >= 80) {
        Broadcast("Grade: B");
    } Alternate Era (grade >= 70) {
        Broadcast("Grade: C");
    } Alternate {
        Broadcast("Grade: F");
    }
    
    // While-style loop with Loop keyword
    Matter counter = 0;
    Loop (counter < 5) {
        Broadcast("Counter value");
        counter = counter + 1;
    }
    
    // For loop - basic
    Loop (Matter i = 0; i < 10; i = i + 1) {
        Broadcast("Loop iteration");
    }
    
    // For loop with break
    Loop (Matter j = 0; j < 20; j = j + 1) {
        Era (j == 10) {
            Escape;  // break
        }
        Broadcast("Before break");
    }
    
    // For loop with continue
    Loop (Matter k = 0; k < 10; k = k + 1) {
        Era (k % 2 == 0) {
            Persist;  // continue
        }
        Broadcast("Odd number");
    }
    
    // Nested control structures
    Matter rows = 3;
    Matter cols = 3;
    Loop (Matter i = 0; i < rows; i = i + 1) {
        Loop (Matter j = 0; j < cols; j = j + 1) {
            Era (i == j) {
                Broadcast("Diagonal element");
            }
        }
    }
    
    // Complex conditions
    Matter a = 5;
    Matter b = 10;
    Matter c = 15;
    Era ((a < b) && (b < c)) {
        Era ((a + b) > c) {
            Broadcast("Triangle inequality holds");
        } Alternate {
            Broadcast("Not a valid triangle");
        }
    }
    
    Broadcast("Control flow test completed");
    Resolve 0;
}
