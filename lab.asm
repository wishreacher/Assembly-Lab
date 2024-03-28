.model small

.stack 100h

.data
    oneCharBuffer db 0                         ; declare oneCharBuffer as a byte variable
    numbers dw 100 dup(2)                       ; declare array as a word variable
    arrayIndex dw 0
    counter db 0
    power dw 0
    inputBuffer dw 0
    isSpace db 0
    isNegative db 0
    sumLow dw 0                                ; Add dx to the low part of the sum
    sumHigh dw 0                               ; Add dx to the high part of the sum
    totalWords dw 0
    overflowOccured db 0

.code 
    main PROC
        mov ax, @data
        mov ds, ax

        call input
        
        call bubbleSort

        call skipLine

        call calculateMedian

        call skipLine

        call calculateAverage

    main ENDP
    
    ; we read symbols one by one. If we read a space, we set a corresponding flag and start reading the next number.
    ; if we read a space ot a new line it means we reached the end of the number and we can start processing it
    input PROC
        inputStart:    
            ;code that reads a character from console
            mov ah, 3Fh
            mov bx, 0h                      ; stdin handle
            mov cx, 1                       ; 1 byte to read
            mov dx, offset oneCharBuffer    ; read to ds:dx 
            int 21h

            or ax, ax
            jz testicleCancer

            mov inputBuffer, ax

            mov ah, 02h
            mov dl, oneCharBuffer
            int 21h

            cmp oneCharBuffer, '-'          ; check if the character is a minus sign
            jne spaceChecks                 ; if it is, jump to negativeNumber
            mov isNegative, 1               ; set the flag to indicate that the number is negative
            jmp inputStart                  ; jump to inputStart

        spaceChecks:
            cmp oneCharBuffer, 0Ah          ; перевірка на переривання рядка
            je popCharacters
            cmp oneCharBuffer, 0Dh          ; перевірка на переривання рядка
            je popCharacters
            cmp oneCharBuffer, 20h          ; перевірка на пробіл
            je popCharacters

            mov isSpace, 0

            push dx                         ; if not a space, push the character onto the stack
            inc counter                     ; increment the counter
            jmp inputEnd

        testicleCancer:
            jmp popCharacters

        inputEnd:
            mov ax, inputBuffer
            or ax, ax                       ; if there's nothing left, the input has ended
            jnz inputStart

            cmp counter, 0                  ; check if there's a number that hasn't been processed
            jne pcJump
            jmp popEnd

        pcJump:
            jmp popCharacters               ; if there's a number left, process it

        popCharacters:
            ; at this point we expect a number stored in the stack in reverse 
            ; order, 1234 - 4321
            inc isSpace
            cmp isSpace, 2
            jne popLoopStart
            jmp popEnd

        popLoopStart: 
            mov cl, counter                 ; number of digits
            xor ax, ax 
            xor dx, dx

        popLoop:
            pop ax                          ; pop a value from the stack into dx
            sub ax, '0'                     ; convert from ASCII to integer

            push cx                         ; save cx
            push dx                         ; save dx
            call powerOfTen                 ; multiply ax by 10 to the power of cx
            cmp overflowOccured, 1
            jne noOverflow

            pop dx 
            pop cx
        overflow:
            mov dx, 32767
            inc power

            jmp popLoopEnd


        noOverflow:
            ;HERE WE ALSO NEED TO CHECK FOR OVERFLOW
            ;FUCK I SPENT 4 HOURS DEBUGGING IT
            pop dx                          ; restore dx
            pop cx                          ; restore cx

            add dx, ax
            cmp dx, 32767
            ja overflow

            inc power

            loop popLoop                    ; decrement cx and continue looping if cx is not zero

        popLoopEnd:
            mov counter, 0
            mov power, 0
            mov overflowOccured, 0

            cmp isNegative, 1               ; check if the number is negative
            jne sum                         ; if it is not, jump to sum
            neg dx

        sum:
            call addToArray

            mov sumHigh, 0                  ;xor dx, dx
            add sumLow, dx
            adc sumHigh, 0

            ;add sumLow, dx ; Add dx to the low part of the sum
            ;adc sumHigh, 0 ; Add with carry to the high part of the sum

            mov dx, 0                       ; clear dx
            mov isNegative, 0               ; clear the negative flag

            jmp inputEnd

        popEnd:
            ret 
    input ENDP

    addToArray proc
        lea bx, [numbers]                   ; load the address of the array into bx
        add bx, arrayIndex                  ; add the arrayIndex to the address
        mov [bx], dx                        ; store the number in the corresponding place in array
        inc arrayIndex                      ; increment the arrayIndex twice because we are storing a word
        inc arrayIndex 
        inc totalWords
        ret
    addToArray endp
    
    powerOfTen PROC
        powerOfTen:
        mov cx, [power]                     ; load the power into cx
        mov bx, 10                          ; base 10 for multiplication

        cmp cx, 0                           ; if the power is 0, we don't need to do anything
        je endPowerOfTen                    ; jump to endPowerOfTen if cx is zero

        powerLoop:
        mul bx                              ; multiply ax by 10
            cmp dx, 0                       ; check if there was an overflow
            jnz hell
            loop powerLoop                  ; decrement cx and continue looping if cx is not zero

        jmp endPowerOfTen

        hell:
        mov ax, 32767
        mov overflowOccured, 1

        endPowerOfTen:
        ret                                 ; return to the caller
    powerOfTen ENDP

    bubbleSort proc
        call clearAllRegisters

        mov cx, totalWords
        dec cx

        outerLoop:
            push cx
            lea si, numbers
        innerLoop:
            mov ax, [si]
            cmp ax, [si+2]
            jl nextStep
            xchg [si+2], ax
            mov [si], ax
        nextStep:
            add si, 2
            loop innerLoop
            pop cx
            loop outerLoop

        ret
    bubbleSort endp

    clearAllRegisters proc
        xor ax, ax
        xor bx, bx
        xor cx, cx
        xor dx, dx
        xor si, si
        ret
    clearAllRegisters endp

    calculateMedian proc
        call clearAllRegisters

        ;divide by two with right shift
        mov bx, totalWords
        mov ax, bx
        and ax, 1                               ; if the least significant bit is 1, the number is odd, we can also shift right by one and if carry flag is 0, the number is even
        jz evenAmount
        jnz oddAmount

        evenAmount:
        shr bx, 1                               ; divide by 2
        dec bx
        lea si, numbers                         ; address of the array

        add bx, bx

        mov dx, [si+bx]                         ; load the first median into dx
        add dx, [si+bx+2]                       ; add the second median to dx

        sub bx, bx

        jmp medianEnd

        oddAmount:
        shr bx, 1                               ; divide by 2
        inc bx                                  ; increment bx by 1 to get the median

        lea si, numbers                         ; address of the array
        mov dx, [si+bx]                         ; load the median into dx

        cmp dx, 0FFh
        jne medianEnd
        mov dx, 0

        medianEnd:
        mov ax, dx
        call decimalOutput

        ret
    calculateMedian endp

    calculateAverage proc
        call clearAllRegisters

        mov dx, sumHigh
        mov ax, sumLow
        mov bx, totalWords
        cwd ; extends the sign of ax to dx

        idiv bx

        call decimalOutput

        ret
    calculateAverage endp

    decimalOutput proc
        push ax                                  
        push bx                                  
        push cx                                  
        push dx                                  

        test ax, ax                             ; check if the number is negative
        jns notNegative

        neg ax                                  ; if it is, flip it

        push ax                                 ; save the number
        push dx                                 ; save the number                

        mov ah, 02h                             ; write minus first 
        mov dl, '-'
        int 21h

        pop dx                                  ; restore the number
        pop ax

    notNegative:
        mov bx, 10                              ; divisor
        mov cx, 0                               ; counter

    divide:
        xor dx, dx                              
        div bx                                  
        push dx                                 ; save the remainder on the stack
        inc cx                                  
        test ax, ax                             ; if the quotient is not zero, continue dividing
        jnz divide                              ; if it is zero, the number has been divided completely

    print_digit:
        pop dx                                  ; pop the remainder from the stack
        add dl, '0'                             ; convert to ASCII
        mov ah, 02h                             
        int 21h                                 
        loop print_digit                        ; repeat until all digits have been printed

        pop dx                                  ; restore registers
        pop cx
        pop bx
        pop ax
        ret                                     
    decimalOutput endp

    skipLine proc
        mov ah, 02h                             ; Function to write a character
        mov dl, 0Ah                             ; ASCII value of newline
        int 21h                                 ; Call DOS interrupt

        ret
    skipLine endp

    end main
.bss 
    