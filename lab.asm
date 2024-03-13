.model small

.data
    iterations db 3; declare how many numbers we want to enter
    oneChar db 00h; declare oneChar as a byte variable
    numbers dw 5 dup(0) ; declare array as a word variable   
    prompt db "Enter a number: $"

.code 
    main PROC
        mov ax, @data
        mov ds, ax

        mov cl, iterations ; set the counter to the number of iterations
        inputloop:
            ;code that outputs a prompt to console
            mov ah, 09h
            lea dx, prompt
            int 21h

            ;code that reads a character from console
            ;mov ah, 01h
            ;int 21h
            mov ah, 3Fh
            mov bx, 0h  ; stdin handle
            mov cx, 1   ; 1 byte to read ;TODO
            mov dx, offset oneChar   ; read to ds:dx 
            int 21h

            ;code that outputs a symbol to console
            mov ah, 02h 
            mov dl, oneChar ;reads the ASCII code from dl register
            int 21h

            ;ВІДСТУП
            ;code that outputs a newline to console
            mov ah, 02h 
            mov dl, 0Ah ; ASCII code for newline
            int 21h

            ;code that outputs a carriage return to console
            mov ah, 02h 
            mov dl, 0Dh ; ASCII code for carriage return
            int 21h

            dec [iterations]
            mov cl, iterations
            jnz inputloop
    main ENDP
    end main
.bss 
    