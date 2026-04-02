// Simple ChronoScript Program
// Basic arithmetic and control flow demonstration

Event main() {
    // Variable declarations
    Matter a = 10;
    Matter b = 20;
    Matter c;
    
    // Arithmetic operations
    c = a + b;
    Matter product = a * b;
    Matter difference = b - a;
    
    // Conditional statement
    Era (a < b) {
        Broadcast("a is less than b");
    } Alternate {
        Broadcast("a is not less than b");
    }
    
    // Loop
    Matter sum = 0;
    Loop (Matter i = 1; i <= 5; i = i + 1) {
        sum = sum + i;
    }
    
    Broadcast("Sum calculated");
    
    Resolve 0;
}
