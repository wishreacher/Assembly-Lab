.model small

.stack 100h

.data
    iterations db 3; declare how many numbers we want to enter
    oneChar db 00h; declare oneChar as a byte variable
    numbers dw 45 dup(2) ; declare array as a word variable   
    prompt db "Enter a number: $"
    index dw 0
    counter db 0
    power dw 0

;читає символи по одному поки не зустрінемо символ пробілу чи рядка
;коли зустріли пробіл чи переривання рядка - записали в масив, опрацювали що там треба
;
.code 
    main PROC
        mov ax, @data
        mov ds, ax

        input:
            ;code that reads a character from console
            mov ah, 3Fh
            mov bx, 0h  ; stdin handle
            mov cx, 1   ; 1 byte to read
            mov dx, offset oneChar   ; read to ds:dx 
            int 21h

            cmp oneChar, 0Ah ; перевірка на переривання рядка
            je popCharacters
            cmp oneChar, 0Dh ; перевірка на переривання рядка
            je popCharacters
            cmp oneChar, 20h ; перевірка на пробіл
            je popCharacters

            push dx; 
            inc counter

            or ax,ax ; якщо тут більше нічого немає, ввід закінчився
            jnz input
            ;TODO оцінити чи буде проблема якшо звідси код піде просто вниз

        popCharacters:
            mov cl, counter ; load the value of counter into cl
            xor ax, ax ; clear ax to store the final number
            xor dx, dx ; clear dx to store the final number

            popLoop:
                pop dx ; pop a value from the stack into dx
                sub dl, '0' ; convert from ASCII to integer
                mov bh, 0 ; clear bh for multiplication


                call powerOfTen ; multiply ax by 10 to the power of cx
                add dx, ax

                add al, dl ; add the new digit
                aam ; adjust after multiply
                inc power

                loop popLoop ; decrement cx and continue looping if cx is not zero

            mov counter, 0


        powerOfTen:
        mov cx, [power] ; load the power into cx
        xor ax, ax ; clear ax to store the final number
        mov bl, 10 ; base 10 for multiplication
        powerLoop:
            mul bl ; multiply ax by 10
            loop powerLoop ; decrement cx and continue looping if cx is not zero
        ret ; return to the caller
    main ENDP
    end main
.bss 
    