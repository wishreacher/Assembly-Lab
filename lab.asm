.model small

.stack 100h

.data
    oneCharBuffer db 00h; declare oneCharBuffer as a byte variable
    numbers dw 45 dup(2) ; declare array as a word variable
    arrayIndex dw 0
    counter db 0
    power dw 0
    inputBuffer dw 0
    isSpace db 0

;читає символи по одному поки не зустрінемо символ пробілу чи рядка
;коли зустріли пробіл чи переривання рядка - записали в масив, опрацювали що там треба
.code 
    main PROC
        mov ax, @data
        mov ds, ax

        call input

        calculations:
        mov ah, 02h
        mov dl, "g"
        int 21h

    main ENDP
    
    addToArray proc
        lea bx, [numbers]
        add bx, arrayIndex
        mov [bx], dx ; store the number in the array
        inc arrayIndex ; increment the arrayIndex twice because we are storing a word
        inc arrayIndex ; TODO this can be done with one instruction
        ret
    addToArray endp

    
    powerOfTen PROC
        powerOfTen:
        mov cx, [power] ; load the power into cx
        mov bx, 10 ; base 10 for multiplication

        cmp cx, 0 ; if the power is 0, we don't need to do anything
        je endPowerOfTen ; jump to endPowerOfTen if cx is zero

        powerLoop:
            mul bx ; multiply ax by 10
            loop powerLoop ; decrement cx and continue looping if cx is not zero

        endPowerOfTen:
        ret ; return to the caller
    powerOfTen ENDP

    input PROC
        inputStart:    
            ;code that reads a character from console
            mov ah, 3Fh
            mov bx, 0h  ; stdin handle
            mov cx, 1   ; 1 byte to read
            mov dx, offset oneCharBuffer   ; read to ds:dx 
            int 21h

            mov inputBuffer, ax

            mov ah, 02h
            mov dl, oneCharBuffer
            int 21h

            cmp oneCharBuffer, 0Ah ; перевірка на переривання рядка
            je popCharacters
            cmp oneCharBuffer, 0Dh ; перевірка на переривання рядка
            je popCharacters
            cmp oneCharBuffer, 20h ; перевірка на пробіл
            je popCharacters

            mov isSpace, 0

            push dx ; if not a space, push the character onto the stack
            inc counter ; increment the counter

            ;TODO this condition check ax, but ax is used in the other place
        inputEnd:
            mov ax, inputBuffer
            or ax, ax ; if there's nothing left, the input has ended
            jnz inputStart

            cmp counter, 0 ; check if there's a number that hasn't been processed
            je calculations

            jmp popCharacters ; if there's a number left, process it

        popCharacters:
            ; at this point we expect a number stored in the stack in reverse 
            ; order, 1234 - 4321
            inc isSpace
            cmp isSpace, 2
            je calculations
             
            mov cl, counter ; number of digits
            xor ax, ax 
            xor dx, dx

        popLoop:
            pop ax ; pop a value from the stack into dx
            sub ax, '0' ; convert from ASCII to integer

            push cx ; save cx
            push dx ; save dx
            call powerOfTen ; multiply ax by 10 to the power of cx
            pop dx ; restore dx
            pop cx ; restore cx

            add dx, ax

            inc power

            loop popLoop ; decrement cx and continue looping if cx is not zero

            mov counter, 0
            mov power, 0

            call addToArray

            jmp inputEnd
            ret ;!!
    input ENDP

    end main
.bss 
    