[org 0x0100]
jmp start

;********* variables **********

offset: dw 3920
box: dw 0x07dc
oldkb: dd 0
oldtimer: dd 0
line1: db 'START !', 0
line2: db 'SCORE: ', 0
line3: db 'MISSED: ', 0
line4: db 'GAME OVER', 0
life: dw 0
score: dw 0
rand: dw 0
randnum: dw 0
char1: dw 0
char1offset: dw 0
char1print: dw 0
char1time: dw 0
char2: dw 0
char2offset: dw 0
char2print: dw 0
char2time: dw 0
char3: dw 0
char3offset: dw 0
char3print: dw 0
char3time: dw 0
char4: dw 0
char4offset: dw 0
char4print: dw 0
char4time: dw 0
char5: dw 0
char5offset: dw 0
char5print: dw 0
char5time: dw 0

;******** printing lines ********

startingline:
push ax
push si
push di
push bx
push cx
call clear
mov ax, 0xb800
mov es, ax
mov di, 1834
mov cx, 7
mov ah, 0x09
mov si, line1
cld
p1:
lodsb
stosw
loop p1
mov bx, 30
l1:
mov cx, 65000
l2:
dec cx
cmp cx, 0
jne l2
dec bx
cmp bx, 0
jne l1
pop cx
pop bx
pop di
pop si
pop ax
ret

endingline:
push ax
push si
push di
push bx
push cx
mov ax, 0xb800
mov es, ax
mov di, 1832
mov cx, 9
mov ah, 0x84
mov si, line4
cld
e1:
lodsb
stosw
loop e1
mov di, 1980
mov cx, 7
mov ah, 0x07
mov si, line2
cld
pp2:
lodsb
stosw
loop pp2
mov di, 2002
mov cx, 8
mov ah, 0x07
mov si, line3
cld
ppp2:
lodsb
stosw
loop ppp2
mov ax, 1994
push ax
push word[score]
call printnum
mov ax, 2018
push ax
push word[life]
call printnum
pop cx
pop bx
pop di
pop si
pop ax
ret

missedline:
push ax
push si
push di
push bx
push cx
mov ax, 0xb800
mov es, ax
mov di, 20
mov cx, 8
mov ah, 0x0E
mov si, line3
cld
p3:
lodsb
stosw
loop p3
pop cx
pop bx
pop di
pop si
pop ax
ret

scoreline:
push ax
push si
push di
push bx
push cx
mov ax, 0xb800
mov es, ax
mov di, 114
mov cx, 7
mov ah, 0x0E
mov si, line2
cld
p2:
lodsb
stosw
loop p2
pop cx
pop bx
pop di
pop si
pop ax
ret

;********* keyboard isr *********

kbisr:

push ax
in al, 0x60
cmp al, 0x4b
jne nextcmp
call clearll
call decbox
call printbox
jmp exit
nextcmp:
cmp al, 0x4d
jne nomatch
call clearll
call incbox
call printbox
jmp exit
nomatch:
pop ax
jmp far [cs:oldkb]
kbreturn:

exit: 
mov al, 0x20
out 0x20, al
pop ax
iret

;********** box movement and printing *********

printbox:
push ax
mov ax, 0xB800
mov es, ax
mov di, word[offset]
mov ax, word[box]
mov word[es:di], ax
pop ax
ret

decbox:
cmp word[offset], 3840
jbe bie
push ax
mov ax, word[offset]
sub ax, 2
mov word[offset], ax
pop ax
jmp biebie
bie:
push ax
mov ax, 3998
mov word[offset], ax
pop ax
biebie:
ret

incbox:
cmp word[offset], 3998
jae bie2
push ax
mov ax, word[offset]
add ax, 2
mov word[offset], ax
pop ax
jmp biebie2
bie2:
push ax
mov ax, 3840
mov word[offset], ax
pop ax
biebie2:
ret

;********** clear functions **********

clear:
push ax
mov ax, 0xB800
mov es, ax
mov di, 0
hello:
mov word[es:di], 0x0720
add di, 2
cmp di, 4000
jne hello
pop ax
ret

clearll:
push ax
mov ax, 0xB800
mov es, ax
mov di, 3840
hello1:
mov word[es:di], 0x0720
add di, 2
cmp di, 4000
jne hello1
pop ax
ret

;********* prints score and life *********

printnum:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigitt: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigitt ; if no divide it again
mov di, [bp+6] ; point di to 70th column
nextposs: pop dx ; remove a digit from the stack
mov dh, 0x07 ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextposs ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 4

numberdisplay:
mov ax, 128
push ax
push word[score]
call printnum
mov ax, 36
push ax
push word[life]
call printnum
ret

;********* timer isr **********

timer:
call character1
call character2
call character3
call character4
call character5
jmp far [cs:oldtimer]

;********** character functions ************

character1:
call numberdisplay
inc word [char1time]
cmp word [char1time], 7
jne midend
mov word [char1time], 0
cmp word [char1print], 0
jne movdown1
mov word[rand], 0
mov word[randnum], 0
call randomsetter
mov ax, 0xb800
mov es, ax
mov di, [char1offset]
mov ax, [char1]
mov word[es:di], ax
inc word [char1print]
jmp end
movdown1:
mov di, [char1offset]
mov word[es:di], 0x0720
add word [char1offset], 160
cmp word [char1offset], 3840
ja changechar1
mov di, [char1offset]
mov ax, [char1]
mov word[es:di], ax
midend:
jmp end
changechar1:
push ax
mov ax, [char1offset]
cmp ax, [offset]
jne inclife
pop ax
inc word [score]
mov word [char1offset], 0
mov word [char1], 0
mov word [char1print], 0
jmp end
inclife:
pop ax
inc word [life]
mov word [char1offset], 0
mov word [char1], 0
mov word [char1print], 0
end:
ret


character2:
call numberdisplay
inc word [char2time]
cmp word [char2time], 3
jne midend2
mov word [char2time], 0
cmp word [char2print], 0
jne movdown2
mov word[rand], 0
mov word[randnum], 0
call randomsetter2
mov ax, 0xb800
mov es, ax
mov di, [char2offset]
mov ax, [char2]
mov word[es:di], ax
inc word [char2print]
jmp end2
movdown2:
mov di, [char2offset]
mov word[es:di], 0x0720
add word [char2offset], 160
cmp word [char2offset], 3840
ja changechar2
mov di, [char2offset]
mov ax, [char2]
mov word[es:di], ax
midend2:
jmp end2
changechar2:
push ax
mov ax, [char2offset]
cmp ax, [offset]
jne inclife2
pop ax
inc word [score]
mov word [char2offset], 0
mov word [char2], 0
mov word [char2print], 0
jmp end
inclife2:
pop ax
inc word [life]
mov word [char2offset], 0
mov word [char2], 0
mov word [char2print], 0
end2:
ret


character3:
call numberdisplay
inc word [char3time]
cmp word [char3time], 15
jne midend3
mov word [char3time], 0
cmp word [char3print], 0
jne movdown3
mov word[rand], 0
mov word[randnum], 0
call randomsetter3
mov ax, 0xb800
mov es, ax
mov di, [char3offset]
mov ax, [char3]
mov word[es:di], ax
inc word [char3print]
jmp end3
movdown3:
mov di, [char3offset]
mov word[es:di], 0x0720
add word [char3offset], 160
cmp word [char3offset], 3840
ja changechar3
mov di, [char3offset]
mov ax, [char3]
mov word[es:di], ax
midend3:
jmp end
changechar3:
push ax
mov ax, [char3offset]
cmp ax, [offset]
jne inclife3
pop ax
inc word [score]
mov word [char3offset], 0
mov word [char3], 0
mov word [char3print], 0
jmp end3
inclife3:
pop ax
inc word [life]
mov word [char3offset], 0
mov word [char3], 0
mov word [char3print], 0
end3:
ret

character4:
call numberdisplay
inc word [char4time]
cmp word [char4time], 11
jne midend4
mov word [char4time], 0
cmp word [char4print], 0
jne movdown4
mov word[rand], 0
mov word[randnum], 0
call randomsetter4
mov ax, 0xb800
mov es, ax
mov di, [char4offset]
mov ax, [char4]
mov word[es:di], ax
inc word [char4print]
jmp end4
movdown4:
mov di, [char4offset]
mov word[es:di], 0x0720
add word [char4offset], 160
cmp word [char4offset], 3840
ja changechar4
mov di, [char4offset]
mov ax, [char4]
mov word[es:di], ax
midend4:
jmp end4
changechar4:
push ax
mov ax, [char4offset]
cmp ax, [offset]
jne inclife4
pop ax
inc word [score]
mov word [char4offset], 0
mov word [char4], 0
mov word [char4print], 0
jmp end4
inclife4:
pop ax
inc word [life]
mov word [char4offset], 0
mov word [char4], 0
mov word [char4print], 0
end4:
ret


character5:
call numberdisplay
inc word [char5time]
cmp word [char5time], 18
jne midend5
mov word [char5time], 0
cmp word [char5print], 0
jne movdown5
mov word[rand], 0
mov word[randnum], 0
call randomsetter5
mov ax, 0xb800
mov es, ax
mov di, [char5offset]
mov ax, [char5]
mov word[es:di], ax
inc word [char5print]
jmp end5
movdown5:
mov di, [char5offset]
mov word[es:di], 0x0720
add word [char5offset], 160
cmp word [char5offset], 3840
ja changechar5
mov di, [char5offset]
mov ax, [char5]
mov word[es:di], ax
midend5:
jmp end
changechar5:
push ax
mov ax, [char5offset]
cmp ax, [offset]
jne inclife5
pop ax
inc word [score]
mov word [char5offset], 0
mov word [char5], 0
mov word [char5print], 0
jmp end5
inclife5:
pop ax
inc word [life]
mov word [char5offset], 0
mov word [char5], 0
mov word [char5print], 0
end5:
ret

;********* random chararcter and number ********

randG:
mov word [rand],0
mov word [randnum],0
push bp
mov bp, sp
pusha
cmp word [rand], 0
jne next
MOV AH, 00h 
INT 1AH
inc word [rand]
mov [randnum], dx
jmp next1
next:
mov ax, 25173
mul word  [randnum]
add ax, 13849
mov [randnum], ax
next1:xor dx, dx
mov ax, [randnum]
mov cx, [bp+4]
inc cx
div cx
add dl,'A'
mov [bp+6], dx
popa
pop bp
ret 2

randGnum:
mov word [rand],0
mov word [randnum],0
push bp
mov bp, sp
pusha
cmp word [rand], 0
jne nextt
MOV AH, 00h 
INT 1AH
inc word [rand]
mov [randnum], dx
jmp next2
nextt:
mov ax, 25173         
mul word  [randnum]   
add ax, 13849     
mov [randnum], ax
next2:xor dx, dx
mov ax, [randnum]
mov cx, [bp+4]
inc cx
div cx
mov [bp+6], dx
popa
pop bp
ret 2

randomsetter:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0E
mov word[char1], ax
mov ax, 0
sub sp, 2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 54
cmp ax, 160
jae mover1
add ax, 160
mover1:
mov word[char1offset], ax
pop ax
ret


randomsetter2:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0C
mov word[char2], ax
mov ax, 0
sub sp, 2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 128
cmp ax, 160
jae mover2
add ax, 160
mover2:
mov word[char2offset], ax
pop ax
ret

randomsetter3:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0D
mov word[char3], ax
mov ax, 0
sub sp, 2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 104
cmp ax, 160
jae mover3
add ax, 160
mover3:
mov word[char3offset], ax
pop ax
ret

randomsetter4:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x09
mov word[char4], ax
mov ax, 0
sub sp, 2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 74
cmp ax, 160
jae mover4
add ax, 160
mover4:
mov word[char4offset], ax
pop ax
ret

randomsetter5:
push ax
sub sp, 2
push 25
call randG
pop ax
mov ah, 0x0A
mov word[char5], ax
mov ax, 0
sub sp, 2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 36
cmp ax, 160
jae mover5
add ax, 160
mover5:
mov word[char5offset], ax
pop ax
ret
;********** start *************

start:
call startingline
call clear
call scoreline
call missedline
call printbox

xor ax, ax
mov es, ax ; point es to IVT base
mov ax, [es:9*4]
mov word[oldkb], ax
mov ax, [es:9*4+2]
mov word[oldkb+2], ax
mov ax, [es:8*4]
mov word[oldtimer], ax
mov ax, [es:8*4+2]
mov word[oldtimer+2], ax
cli
mov word [es:9*4], kbisr
mov [es:9*4+2], cs
mov word [es:8*4], timer
mov [es:8*4+2], cs
sti

label:
cmp word[life], 10
jae finalexit
jmp label

finalexit:

cli
xor ax, ax
mov es, ax
mov cx, [oldtimer]
mov dx, [oldtimer+2]
mov word [es:8*4], cx
mov word [es:8*4+2], dx
sti
call clear
mov word[life], 10
call endingline
mov dx, start
add dx,15
mov cl, 4
shr dx, cl
mov ax, 0x3100
int 21h