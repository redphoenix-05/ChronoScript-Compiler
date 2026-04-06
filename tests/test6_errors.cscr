// Test 6: Syntax Error Detection
// This file contains intentional syntax errors to test error recovery

Event main() {
    // ERROR 1: Missing semicolon
    Matter x = 10
    
    // ERROR 2: Mismatched parentheses
    Era (x > 5 {
        Broadcast("Error test");
    }
    
    // ERROR 3: Invalid expression
    Matter y = 5 +;
    
    // ERROR 4: Missing closing brace (commented to allow further parsing)
    // Era (y < 10) {
    //     Broadcast("Missing brace");
    
    // ERROR 5: Invalid operator usage
    Matter z = * 10;
    
    // ERROR 6: Incomplete for loop
    Loop (Matter i = 0; i < 10) {
        Broadcast("Missing increment");
    }
    
    // ERROR 7: Missing function body
    // Matter badFunction() 
    
    // ERROR 8: Invalid assignment
    10 = x;
    
    Resolve 0;
}
