%include "io.inc"

section .text
global main
main:
    mov ebp, esp ;; for correct debugging
    ;; write your code here
    
    ;; Prompt the user to enter their username:
    PRINT_STRING [enter_name]
    GET_STRING [input_name], 100
    lea esi, [input_name] 
    call remove_newline 
    mov ecx, [length]
    sub ecx, 1 
    mov [name_length], ecx 
    PRINT_STRING [input_name]
    NEWLINE
    
    ;; Prompt the user to enter their password:
    PRINT_STRING [enter_pass]
    GET_STRING [input_pass], 100
    lea esi, [input_pass]
    call remove_newline 
    mov ecx, [length] 
    sub ecx, 1 
    mov [pass_length], ecx 
    PRINT_STRING [input_pass]
    NEWLINE
    
    ;; Checks if the inputted username is USER1, if so jump to check_user_pass:
    lea esi, [input_name] 
    lea edi, [user_name] 
    call strings_equal 
    cmp eax, 1
    je verify_user
    
    ;; Checks if the inputted username is ADMIN, if so jump to check_admin_pass:
    lea edi, [admin_name] 
    call strings_equal 
    cmp eax, 1 
    je verify_admin 
    
    ;; Checks if the inputted username is GUEST, if so jump to check_guest_pass:
    lea edi, [guest_name] 
    call strings_equal 
    cmp eax, 1 
    je verify_guest 
    
    ;; If it is not a valid user, access_denied: "Access Denied"
    jmp access_denied
    
;; Contract: string string  -> string
;; Purpose: The entered username and password for USER1 are correct, prompt the
;; access level that is granted based on their info, then prompt twofa to then
;; validate the result
verify_user:
    lea esi, [input_pass] 
    lea edi, [user_pass] 
    call strings_equal 
    cmp eax, 0 
    je access_denied 
    PRINT_STRING "Level 1 Access Granted"
    NEWLINE
    jmp twofa

;; Contract: string string -> string
;; Purpose: The entered username and password for ADMIN are correct, prompt the
;; access level that is granted based on their info, then prompt twofa to then
;; validate the result
verify_admin:
    lea esi, [input_pass]
    lea edi, [admin_pass]
    call strings_equal 
    cmp eax, 0 
    je access_denied
    PRINT_STRING "Level 2 Access Granted"
    NEWLINE
    jmp twofa

;; Contract: string string -> string
;; Purpose: The entered username and password for GUEST are correct, prompt the
;; access level that is granted based on their info, then prompt twofa to then
;; validate the result
verify_guest:
    lea esi, [input_pass] 
    lea edi, [guest_pass] 
    call strings_equal
    cmp eax, 0 
    je access_denied
    PRINT_STRING "Guest Access Granted"
    NEWLINE
    jmp twofa

;; Contract: -> string
;; Purpose: Compares the inputted value to solve the math problem 5 + 7 = ? and compares
;; the value with 12 which is the expected value, returns 1 if it passes, returns 0,
;; if it fails
twofa:
    PRINT_STRING [twofa_prompt]
    GET_DEC 1, eax 
    PRINT_DEC 1, eax 
    NEWLINE
    cmp eax, [twofa_correct_answer] 
    je validation_success 
    jmp validation_fail
    
;; Contract: -> string
;; Purpose: If the 2fa fails and does not pass, then print out "Validation Failed", meaning
;; the user has not solved 5 + 7 = ? and answered incorrectly
validation_fail:
    PRINT_STRING "Validation Failed"
    jmp exit

;; Contract: -> string
;; Purpose: If the 2fa fails and does pass, then print out "Validation Success", meaning
;; the user has solve 5 + 7 = 12 and answered correctly
validation_success:
    PRINT_STRING "Validation Successful"
    jmp exit

;; Contract: -> string
;; Purpose: If the password is incorrect of if the user is not a valid user of the three
;; given options then print "Access Denied"
access_denied:
    PRINT_STRING "Access Denied"
    jmp exit

;; Contract: -> boolean
;; Purpose: Checks if the inputted string is equal to the length of the expected
;; string and xor eax register to avoid any bugs or errors when comparing bytes
strings_equal:
    xor eax, eax 
    call string_length 
    mov ebx, [length] 
    mov [temp_addr], esi 
    mov esi, edi 
    call string_length 
    mov edx, [length] 
    cmp bl, dl 
    jne strings_not_equal 
    mov esi, [temp_addr] 
    jmp strings_equal_loop 

;; Contract: string string -> boolean
;; Purpose: Recursively check over the inputted string with the expected string
;; to see if they are equal to each other
strings_equal_loop:
    mov al, [esi] 
    cmp al, 0 
    je strings_are_equal 
    cmp al, [edi] 
    jne strings_not_equal 
    inc esi 
    inc edi 
    loop strings_equal_loop 
    
;; Contract: -> boolean
;; Purpose: Sets up if the result is true, determined and identified by (1)
strings_are_equal:
    xor ebx, ebx 
    xor edx, edx 
    mov eax, 1 
    ret 

;; Contract: -> boolean
;; Purpose: Sets up if the result is false, determined and identified by (0)
strings_not_equal:
    xor ebx, ebx 
    xor edx, edx 
    xor eax, eax 
    ret

;; Contract: string -> integer
;; Purpose: Gets the length of string value and returns back an integer representing
;; the string's length
string_length:
    xor ecx, ecx

;; Contract: -> integer
;; Purpose: Counts up the total length of the string and is able to obtain the total 
;; length value, called recursively until the length_done = 0
string_length_loop:
    mov al, [esi + ecx] 
    cmp al, 0 
    je end_length ;; Null terminator
    inc ecx 
    jmp string_length_loop 
    end_length:
    mov [length], ecx 
    xor ecx, ecx 
    ret 

;; Contract: string -> string
;; Purpose: Removes the newline character created when a user presses enter 
;; from inputted string
remove_newline:
    call string_length 
    mov ecx, [length] 
    mov byte [esi + ecx - 1], 0 ;; Null terminator
    xor ecx, ecx 
    ret

;; Contract -> void
;; Purpose: Terminate the program and xor every register to avoid any bugs or crashes
;; that can happen in the program
exit:
    xor eax, eax 
    xor ebx, ebx 
    xor ecx, ecx 
    xor edx, edx 
    xor esi, esi 
    xor edi, edi 
    ret

section .data
;; Options for the user to choose from to log in with their 
;; appropriate password
user_name db "USER1", 0
admin_name db "ADMIN", 0
guest_name db "GUEST", 0
user_pass db "USERPASS", 0
admin_pass db "ADMINPASS", 0
guest_pass db "GUESTPASS", 0

;; 2-step auth messages and info
twofa_prompt db "Solve: 5 + 7 = ", 0
twofa_correct_answer dd 12
twofa_user_answer dd 0

;; User prompts for the user and messages
enter_name db "Enter username: ", 0
enter_pass db "Enter password: ", 0

;; User input for storage, reserving 100 bytes
input_name db 100 dup(0)
input_pass db 100 dup(0)
input_2FA dd 0

;; Set up variables for the size of the inputs
length dd 0
temp_addr dd 0
name_length dd 0
pass_length dd 0
