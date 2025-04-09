;neka je dat niz integera, gde se tacno 2 elementa pojavljuju 1nom 
;a svi ostali elementi se ponavljaju tacno 2put. 
;naci ta 2 elementa koji se ponavljaju tacno jednom. paziti na efikasnost. 

data segment     
    poruka1 db "Unesite broj elemenata niza: $"
    strNizDuz db "       "
    nizDuzina dw 0
    poruka2 db "Unesite broj(dva elementa se pojavljuju jednom a ostali dva puta): $"
    strN db "       "
    n dw 0
    niz dw 100 dup(0)
    poruka3 db "Elementi koji se pojavljuju jednom: $"
    strBr1 db "       "
    broj1 dw 0         
    strBr2 db "       "
    broj2 dw 0    
    poruka4 db "Pritisnite neki taster...$"
data ends

stek segment
    dw 128 dup(0)
stek ends
             
; Ispis znaka na ekran  
write macro c
    push ax   
    push dx
    mov ah, 02
    mov dl, c
    int 21h
    pop dx
    pop ax
endm
             
; Ucitavanje znaka bez prikaza i cuvanja     
keypress macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm
; Isis stringa na ekran
writeString macro s
    push ax
    push dx  
    mov dx, offset s
    mov ah, 09
    int 21h
    pop dx
    pop ax
endm
; Kraj programa           
krajPrograma macro
    mov ax, 4c02h
    int 21h
endm   


code segment                           

; pronalazi dva elementa niza koja se ne ponavljaju
; u steku se nalazi vrednosti broj1 i broj2
pronadji proc  
    push ax
    push bx
    push cx
    push dx  
    push si
    push di    
    
    mov bp, sp              
    mov cx, nizDuzina       ; u CX postavljamo duzinu niza*2             
    add cx, nizDuzina  
    mov dx, 2               ; DX koristimo kao pomoc za cuvanje brojeva 
    
    mov si, 0               ; SI postavljamo za prvi element niza
    mov di, 2               ; DI postavljamo za sledeci element niza
    mov ax, niz[si]         ; u AX postavljamo prvi broj niza
           
    trazi:  
        cmp di, cx           ; ako je DI poslednji element niza znaci da se trenutni broj nigde ne ponavlja
        je sacuvaj           ; i skacemo na labelu sacuvaj
        cmp ax, niz[di]      ; uporedjujemo trenutni broj sa sledecim
        je podesavanje       ; ako su jednaki prelazimo na podesavanjeg sledeceg elementa
        add di, 2            ; ako nisu jednaki dodajemo 2 u DI za sledeci element
        jmp trazi            ; i ponovo skacemo na trazi labelu 
    
    sacuvaj:
        prviBroj:
            cmp dx, 2
            jne drugiBroj
            mov [bp+16], ax     ; cuvamo prvi broj
            dec dx
            jmp podesavanje
        drugiBroj:
            cmp dx, 1
            jne oslobodiStek
            mov [bp+14], ax     ; cuvamo drugi broj
            jmp oslobodiStek
       
    podesavanje:                ; ako su dva elementa jednaka skacemo ovde                                
        push ax                 ; stavljamo broj u stek
        add si, 2               ; dodajemo 2 u SI za zledeci element
        mov di, si              ; u DI postavljamo SI + 2
        add di, 2
        mov ax, niz[si]         ; u AX postavljamo sledeci broj
        proveriStek:
            sub di, 2
            cmp di, 0
            je nastavi          ; ako je DI=0 znaci da smo prosli sve brojeve iz steka i mozemo da nastavimo
            mov bx, bp          ; u BX postavljamo vrednost BP
            sub bx, di          ; i oduzimamo DI     
            cmp ax, [bx]        ; uporedjuje broj iz AX i broj sa steka koji se nalazi na lokaciji BX
            je podesavanje      ; ako su brojevi jednaki ponovo skacemo na labelu podesavanje
            jmp proveriStek     ; ako nisu skacemo ponovo na proveriStek labelu
        nastavi:
            mov di, si          ; u DI prebacujemo vrednost SI
            add di, 2           ; dodajemo 2  za sledeci element niza
            jmp trazi           ; vracamo se na labelu trazi za ponovno trazenje
                                
    oslobodiStek:               ; skidamo sa steka sve brojeve koje smo ubacili kod podesavanja
        cmp si, 0
        je kraj
        sub si, 2
        pop di
        jmp oslobodiStek
     
    kraj:  
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
pronadji endp

; Novi red
novired proc
    push ax
    push bx
    push cx
    push dx
    mov ah,03
    mov bh,0
    int 10h
    inc dh
    mov dl,0
    mov ah,02
    int 10h
    pop dx
    pop cx
    pop bx
    pop ax
    ret
novired endp
; Ucitavanje stringa sa tastature
; Adresa stringa je parametar na steku
readString proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp, sp
    mov dx, [bp+12]
    mov bx, dx
    mov ax, [bp+14]
    mov byte [bx] ,al
    mov ah, 0Ah
    int 21h
    mov si, dx     
    mov cl, [si+1] 
    mov ch, 0
kopiraj:
    mov al, [si+2]
    mov [si], al
    inc si
    loop kopiraj     
    mov [si], '$'
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
readString endp
; Konvertuje string u broj
strtoint proc
    push ax
    push bx
    push cx
    push dx
    push si
    mov bp, sp
    mov bx, [bp+14]
    mov ax, 0
    mov cx, 0
    mov si, 10
petlja1:
    mov cl, [bx]
    cmp cl, '$'
    je kraj1
    mul si
    sub cx, 48
    add ax, cx
    inc bx  
    jmp petlja1
kraj1:
    mov bx, [bp+12] 
    mov [bx], ax 
    pop si  
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
strtoint endp
; Konvertuje broj u string
inttostr proc
   push ax
   push bx
   push cx
   push dx
   push si
   mov bp, sp
   mov ax, [bp+14] 
   mov dl, '$'
   push dx
   mov si, 10
petlja2:
   mov dx, 0
   div si
   add dx, 48
   push dx
   cmp ax, 0
   jne petlja2
   
   mov bx, [bp+12]
petlja2a:      
   pop dx
   mov [bx], dl
   inc bx
   cmp dl, '$'
   jne petlja2a
   pop si  
   pop dx
   pop cx
   pop bx
   pop ax 
   ret 4
inttostr endp  
          
        
    
    
start:
    ASSUME cs: code, ss:stek
    mov ax, data
    mov ds, ax        
               
    writeString poruka1
    push 3
    push offset strNizDuz
    call readString 
    call novired
    
    push offset strNizDuz
    push offset nizDuzina
    call strtoint
            
    mov cx, nizDuzina       
    mov si, 0
unos:
    ; Ucitavanje broja u string                  
    call novired
    writeString poruka2
    push 7
    push offset strN
    call readString    
    ; Konvertovanje stringa u broj
    push offset strN
    push offset n
    call strtoint 
    ; Smestanje broja u niz
    mov ax, n
    mov niz[si], ax 
    ; SI se poveca za 2 kako bi dobio poziciju sledeceg elementa u nizu, jer su elementi niza veliki 2 bajta.
    add si, 2
    loop unos    
dalje:                
    push broj1
    push broj2              
    call pronadji  
    
    pop broj2
    pop broj1
                
    push broj1
    push offset strBr1
    call inttostr
    
    push broj2
    push offset strBr2
    call inttostr
       
    call novired   
    call novired
    writeString poruka3  
    writeString strBr1
    write ' ' 
    writeString strBr2  
    
    call novired     
    call novired
    writeString poruka4
    keypress
    krajPrograma
ends
end start         