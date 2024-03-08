.model small

.data
db oneChar 0

.code 
    main PROC
        
        
        read_next:
        mov ah, 3Fh
        mov bx, 0h  ; stdin handle
        mov cx, 10   ; 1 byte to read
        mov dx, offset oneChar   ; read to ds:dx 
        int 21h   ;  ax = number of bytes read
        ; do something with [oneChar]

        ;code that outputs a symbol to console
        mov ah, 02h 
        mov dl, [oneChar] ;reads the ASCII code from dl register
        int 21h
        ;or ax,ax
        ;jnz read_next

    main ENDP
    end main

.bss 
    