.model small

.stack 100h

.data
    oneCharBuffer db 0; declare oneCharBuffer as a byte variable
    numbers dw 10 dup(2) ; declare array as a word variable
    arrayIndex dw 0
    counter db 0
    power dw 0
    inputBuffer dw 0
    isSpace db 0
    isNegative db 0
    sumLow dw 0; Add dx to the low part of the sum
    sumHigh dw 0; Add dx to the high part of the sum
    totalWords dw 0

;читає символи по одному поки не зустрінемо символ пробілу чи рядка
;коли зустріли пробіл чи переривання рядка - записали в масив, опрацювали що там треба
.code 
    main PROC
        mov ax, @data
        mov ds, ax

        mov ax, 455
        call StdoutDecimal
        ;call input
        ;call bubbleSort
        ;call calculateMedian
        ;call calculateAverage

    main ENDP
    
    addToArray proc
        lea bx, [numbers]
        add bx, arrayIndex
        mov [bx], dx ; store the number in the array
        inc arrayIndex ; increment the arrayIndex twice because we are storing a word
        inc arrayIndex ; TODO this can be done with one instruction
        inc totalWords
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

            or ax, ax
            jz testicleCancer

            mov inputBuffer, ax

            mov ah, 02h
            mov dl, oneCharBuffer
            int 21h

            cmp oneCharBuffer, '-' ; check if the character is a minus sign
            jne spaceChecks ; if it is, jump to negativeNumber
            mov isNegative, 1 ; set the flag to indicate that the number is negative
            jmp inputStart ; jump to inputStart

        spaceChecks:
            cmp oneCharBuffer, 0Ah ; перевірка на переривання рядка
            je popCharacters
            cmp oneCharBuffer, 0Dh ; перевірка на переривання рядка
            je popCharacters
            cmp oneCharBuffer, 20h ; перевірка на пробіл
            je popCharacters

            mov isSpace, 0

            push dx ; if not a space, push the character onto the stack
            inc counter ; increment the counter
            jmp inputEnd

        testicleCancer:
            jmp popCharacters

        inputEnd:
            mov ax, inputBuffer
            or ax, ax ; if there's nothing left, the input has ended
            jnz inputStart

            cmp counter, 0 ; check if there's a number that hasn't been processed
            jne pcJump
            jmp calculationStart

        pcJump:
            jmp popCharacters ; if there's a number left, process it

        popCharacters:
            ; at this point we expect a number stored in the stack in reverse 
            ; order, 1234 - 4321
            inc isSpace
            cmp isSpace, 2
            jne popLoopStart
            jmp calculationStart

        popLoopStart: 
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

        popLoopEnd:
            mov counter, 0
            mov power, 0

            call floor

            cmp isNegative, 1 ; check if the number is negative
            jne sum ; if it is not, jump to sum
            neg dx

        sum:
            call addToArray

            mov sumHigh, 0 ;xor dx, dx
            add sumLow, dx
            adc sumHigh, 0

            ;add sumLow, dx ; Add dx to the low part of the sum
            ;adc sumHigh, 0 ; Add with carry to the high part of the sum

            mov dx, 0 ; clear dx
            mov isNegative, 0 ; clear the negative flag

            jmp inputEnd
            ret ;!!
    input ENDP

    floor proc
        cmp dx, 32767
        jno endFloor
        mov dx, 32767
        
        endFloor:
        ret
    floor endp

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

    calculation proc
        calculationStart:
            ret
    calculation endp

    calculateMedian proc
        call clearAllRegisters

        ;divide by two with right shift
        mov bx, totalWords
        mov ax, bx
        and ax, 1
        jz evenAmount
        jnz oddAmount

        evenAmount:
        shr bx, 1
        lea si, numbers

        mov dx, [si+bx]
        add dx, [si+bx-2]

        jmp medianEnd

        oddAmount:
        shr bx, 1
        inc bx

        lea si, numbers ; address of the array
        mov dx, [si+bx] ; load the median into dx

        medianEnd:
        call convertAss
        ret
    calculateMedian endp

    calculateAverage proc
        call clearAllRegisters

        mov dx, sumHigh
        mov ax, sumLow
        mov bx, totalWords
        cwd ; TODO understand what this does

        idiv bx
        mov dx, ax

        call convertAss

        ret
    calculateAverage endp

    convertAss PROC
        minusCheck:
            xor cx, cx

            test dx, 8000h ; check if the number is negative   
            jz conversion

            neg dx
            push '-'
            inc cx

        conversion:
            mov ax, dx
            xor dx, dx
            mov bx, 10 ; constant for division

            div bx
            add dx, '0' ; convert to ASCII
            push dx
            inc cx
            test ax, ax
            jne conversion

            jmp printLoop
        ret
    convertAss ENDP

    printAss PROC
        printLoop:
            xor dx, dx
            pop dx
            mov ah, 02h
            int 21h
            loop printLoop
        ret
    printAss ENDP
StdoutDecimal proc
    push ax                                  
    push bx                                  
    push cx                                  
    push dx                                  

    test ax, ax
    jns notNegative

    neg ax

    push ax
    push dx

    mov ah, 02h
    mov dl, '-'
    int 21h

    pop dx 
    pop ax

notNegative:
    mov bx, 10                               ; Дільник для перетворення у десятковий формат
    mov cx, 0                                ; CX буде рахувати кількість цифр

divide:
    xor dx, dx                               ; Очищення DX для DIV
    div bx                                   ; Ділення AX на BX
    push dx                                  ; Запис залишку (цифри) у стек
    inc cx                                   ; Збільшуємо каунтер цифр на 1 
    test ax, ax                              ; Перевірка чи результат ділення 0
    jnz divide                               ; Якщо ні, продовжуємо ділення

print_digit:
    pop dx                                   ; Дістаємо цифру зі стеку
    add dl, '0'                              ; Конвертація у ASCII
    mov ah, 02h                              ; Код функції stdout
    int 21h                                  ; Виклик DOS переривання
    loop print_digit                         ; Повторення поки всі цифри не будуть надруковані

    pop dx                                   ; Відновлення регістрів
    pop cx
    pop bx
    pop ax
    ret                                      ; Повернення з підпрограми
StdoutDecimal endp

    end main
.bss 
    