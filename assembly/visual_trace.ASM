; Very first trace of some ASM before I understood what was going on.

;This all begins at segment 8312
;Breakpoint set at reading the first byte of "no", 82 cc, the second character in the first row, at 837fb

;40b3: 

40b3 ac lodsb            ;(reads the first byte)
40b4 0ac0 or al, al
40b6 7503 jnz 40bb
->
	40bb 3c20 cmp al, 20      ;(checks if it's a control code?)
	40bd 7203 jb 40c2
	40bf e9bb02 jmp 437d
	->
		437d e87efc call 3ffe
		->
			3ffe 50 push ax
			3fff 51 push cx
			4000 56 push si
			4001 2e8a269d40 mov ah, cs:[409d]    ;(05 00 06 00)?
			4006 0ae4 or ah, ah
			4008 7524 jnz 402e
			400a 3c80 cmp al, 80          ;(below 80, it calls 401e, also used for halfwidth kana-ignoring)
			400c 7210 jb 401e
			400e eca0 cmp al, a0
			4010 7204 jb 4016
			->
				4016 2ea29d40 mov cs:[409d], al
				401a 33c9 xor cx, cx
				401c eb6c jmp 408a
				->
					408a e30d jcxz 4099 ;(jump if ECX register is zero)
					->
						4099 5e pop si
						409a 59 pop cx
						409b 58 pop ax
						409c c3 ret
						<-
					4380 e83dee call 31c0
					->
						31c0 60 pusha
						31c1 2e803eda3100 cmp cs:[31da], 00  ;(it's 01)
						31c7 7503 jnz 31cc
						->
							31cc b83c00 mov ax, 003c
							31cf e83cce call 000e
							->
								000e 50 push ax
								000f 2ea1cc30 mov ax, cs:[30cc]
								0013 2ea3c830 mov cs:[30c8], ax
								0017 2ea1ca30 mov ax, cs:[30ca]
								001b 2ea3c630 mov cs:[30c6], ax
								001f 58 pop ax
								0020 2eff1ec630 call far cs:[30c6]
								->
									18b8:63fc 55 push bp
									63fd bd6063 mov bp, 6360
									6400d1e0 shl ax, 1
									6402 03e8 add bp, a
									6404 2eff5600 call cs:[bp+00]
									6408 5d pop bp
									6409 cb retf
									<-
								18b8:6ce3 1e push ds
								6ce4 b89f1f mov ax, 1f9f
								6ce7 8ed8  mov ds, ax
								6ce9 e8efae call 1bdb
								->
									18b8:1bdb 33db xor bx, bx
									1bdd 803e922a00 cmp [2a92], 00
									1be2 7409 jz 1bed
									->
										18b8:1bed 32ed xor ch, ch
										1bef b10a mov cl, 0a
										1bf1 e8f600 call 1cea
										->
											;(some moves that set EAX to 0408)
											18b8:1cee cd18 int 18 ;(interrupt KEY PRESSED??)
											->
												sti, lc, nop, iret
												<-
											1cf0 f6c408 test ah, 08
											1cf3 7403 jz 1cf8
											->
												1cf8 f6c440 test ah, 40
												1cfb 7403 jz 1d00
												->
													1d00 b404 mov ah, 04
													1d02 b009 mov al, 09
													1d04 cd18 int 18 ;(interrupt KEY PRESSED?) -> sti, lc, nop, iret <-
													1d08 f6c408 test ah, 08
													1d09 7403 jz 1d0e
													->
														1d0e f6c401 test ah, 01
														1d11 7403 jz 1d16
														->
															1d16 b404 mov ah, 04
															1d18 b005 mov al, 05
															1d1a cd18 int 18 ;(interrupt KEY PRESSED?) -> sti, lc, nop, iret <-
															1d1c f6c402 test ah, 02
															1d1f 7403 jz 1d24
															->
																1d24 f6c404 test ah, 04
																1d27 7403 jz 1d2c
																->
																	1d2c b404 mov ah, 04
																	b00a mov al, 0a

																;(etc. lots of tests for keyboard input)
								0025 c3 ret
								<-
							31d2 8e230 and dx, +30
							31d5 7401 jz 31d8
							->
								31d8 61 popa
								31d9 c3 ret
								<-
						4383 7303 jnb 4388
						4385 e98cec jmp 3014
						4388 e928fd jmp 40b3
						438b 07 pop es
						438c 1f pop ds
						438d 61 popa
						438e c3 ret
						<-
					40b3 ac lodsb
					40b4 0ac0 or al, al
					40b6 7503 jnz 40bb
					->
						;(40bb is listed above. Compares it to 20, etc)
						eventually,
						4006 0ae4 or ah, ah
						4008 7524 jnz 402e
						->
							402e 2ec6069d400 mov cs:[409d], 00
							4034 e872fa call 3aa9
							->
								3aa9 60 pusha
								3aaa 06 push es
								3aab fc cld
								3aac 8ccb mov bx, cs
								3aae 8edb mov ds, bx
								3ab0 8ec3 mov es, bx
								8ab2 bf043c mov di, 3c04
								3ab5 50 push ax
								3ab6 b00b mov al, 0b
								3ab8 e68 out 68
								3aba 58 pop ax     ;(loads 82cc, the char, back into ax)
								3abb 0ae4 or ah, ah
								3abd 7503 jnz 3ac2
								->
									3ac2 e87203  call 3e37
									->
										3e37 02e4 add ah, ah  ;(04cc)
										3e39 2c1f sub al, 1f  ;(04ad)
										3e3b 7804 js 3e41 ;(jump if sign flag, like if al became negative)
										->
											3e41 05a11f add ax, 1fa1    ;(244e)
											3e44 257f7f and ax, 7f7f    ;(still 244e)
											3e47 c3 ret
											<-
										<-
									3ac5 2d0020 sub ax, 2000        (044e)
									3ac8 e6a1 out al, al    (???)
									3aca 8ac4 mov al, ah            (0404)
									3acc e6e3 out a3, al    (???)
									3ace 32d2 xor dl, dl
									3ad0 57 push di
									3ad1 b91000 mov cx, 0010
									(3ad4 8ac2 mov al, dl
									3ad6 e6a5 out a5, al
									3ad8 e4a9 in al, a9
									3ada 8ae0 mov ah, al
									3adc 8ac2 mov al, dl
									3ade 0c20 or al, 20
									3ae0 e6a5 out a5, al
									3ae2 e4a9 in al, a9
									3ae4 ab stosw          (stores the word in AX (0000) at [ES:DI].)
									3ae5 fec2 inc dl
									3ae7 e2eb loop 3ad4^

									3ae9 5e pop si
									3aea bf263c mov di, 3c26
									3aed bb263e mov bx, 3e26
									3af0 b91000 mov cx, 0010

									(3af3 ac lodsb
									3af4 8ae0 mov ah, al
									3af6 c0e804 shr al, 04
									xlat something
									3afa 86e0 xchg al, ah (both 00)
									3afc 240f and al, 0f
									3afe d7 xlat
									3aff 86e0 xchg al, ah
									3b01 8905 mov [di], ax
									(a bunch of movs from empty ax into various memory locations)
									3b21 ac lodsb (still loading 00 from [DS:SI]
									more weird pointless things
									3b4f e2a2 loop 3af3 ^

									3b51 8a1e363e mov bl, [3e36]
									3b55 8afb mov bh, bl
									3b57 c0e704 shl bh, 04
									3b5a 0adf or bl, bh
									3b5c be963c mov si, 3c96
									3b5f bf9e3c mov di, 3c9e
									3b62 b90f00 mov cx, 000f

									;more stuff

											mov si, 3c26 
											mov ax, a800
											call 3f3a
											->
												move lots of bytes to the first plane of VRAM
												mov es, ax
												mov cx, bp
												repe movsw ;(repeat movsw the number of times, usually 2)
													;(movsw moves word at [DS:SI] to [ES:DI])
													;(move 300c to somewhere in VRAM)
											;then move stuff to the other 3 planes of VRAM
											<-
										call 33c6
										->
											33c6 9c pushf
											33c7 50 push ax
											33c8 1e push ds
											;pushes and outs and stuff
											;...
											;then it calls the thing that writes to VRAM again

											403a 83c704 add di, +04
											403d  3d4181 cmp ax, 8141
											4040 7414 jz 4056
											4042 3d4381 cmp ax, 8143
											4045 740f jz 4056
											4047 3d4581 cmp ax, 8145
											404a 704a jz 4056
											404c 3d4981 cmp ax, 8149
											404f 7405 jz 4056
											4051 3d4081 cmp ax, 8140
											4054 7507 jnz 405d
											->
												405d 3d4281 cmp ax, 8142
												4060 7405 jz 4067
												4062 3d4481 cmp ax, 8144
												4065 7507 jnz 406e
												->
													406e 2e803efd3f00 cmp cs:[3ffd], 00
													4074 750f jnz 4085
													4076 53 push bx
													4077 52 push dx
													4078 bb1300 mov bx, 0013
													407b b600 mov dh, 00
													407d b81600 mov ax, 0016
													4080 e88bbf call 000e
													->
														000e 50 push ax
														000f 2ea1cc30 mov ax, cs:[30cc]
														0013 2ea3c830 mov cs:[30c8], ax
														0017 2ea1ca30 mov ax, cs:[30ca]
														001b 2ea3c630 mov cs:[30c6], ax
														001f 58 pop ax
														0020 2eff1ec630 call far cs:[30c6]
														->
															18b8:63fc 55 push bp
															63fd bd6063 mov bp, 6360
															6400 d1e0 shl ax, 1
															6402 03e8 add bp, ax
															6404 call cs:[bp+00]
															->
																18b8:69ac 60 pusha
																69ad 1e push ds
																69ae 06 push es
																69af b89f1f mov ax, 1f9f
																69b2 8ec0 mov es, ax
																69b4 26803e922a00 cmp es:[2a92], 00
																69ba 7416 jz 69d2

															;(How'd I get here?)
																fd80:022d push ds
																022e xor ax, ax
																8ed8 mov ds, ax
																0232 e44e in al, 43
																0234 test al, 38
																0236 jnz 025a
																0238 mov al, 16
																023a out 43, al
																023c mov [0529], 00
																0241 in al, 41
																0243 mov ah, al
																0245 call 0088
																->
																	nop ret
																	<-
																0248 pop ds
																0249 cli
																024a mov al, 20
																024c out 00, al
																024e cmp ah, 60
																0253 cmp ah, 61
																0256 jz 026d
																0258 pop ax
																0259 iret
																<-
															18b8:69ad push ds
															->
																;(how'd I get here again?)
																fd80:022d (detailed above)
															69ae push es
															69af mov ax, 1f9f
															69b2 mov es, ax
															69b4 cmp es:[2a92], 00
															69ba jz 69d2

										;The "display stuff" routine is somewhere in the 18b8 segment.
										18b8:1650 50 push ax
										1651 2eff066d16 inc word ptr cs:[166d]
										1656 b022 mov al, 22
										1658 e600 out 00, al
										165a e664 out 64, al
										165c 58 pop ax
										165d fb sti      ;<- here it is??? The character is displayed after this instruction.
										165e cf iret



			4012 3ce0 cmp al, e0      ;(branch between a0 and e0 = halfwidth kana??)
			4014 7208 jb 401e         ;(now, what happens in 401e? put some halfwidth kana in and find out)
			4016 2ea29d40 mov cs:[409d], al
			401a 33c9 xor cx, cx
			401c eb6c jmp 408a



;HALFWIDTH KANA a8:

;starting at that jump to 401e:
401e e888fa call 3aa9
->
	3aa9 60 pusha  ;(this is detailed above already. Just the text routine without the 'load 2nd byte' bit)
	3aaa 06 push es
	3aab fc cld
	3aac 8ccb mov bx, cs
	;...
	;...

;lots of moves (movsw) from DS:SI to ES:DI, or 62f6:2482 () to b800:2832 (3rd VRAM plane)

;loop with counter BX at 05: (row? Starts at like x18)
;	inner loop with counter CX at 02: (column? starts at like x7)
;		SI goes up: 24bc +1 each CX loop
;		DI (VRAM index) goes up: 27e0 +1 each CX loop
;	DI (VRAM index) goes up by DX: 282e

	


;Some questions:
;Which file is at x18b8? (it's JO.EXE)
;So, where is the font held in memory??
;	Loaded the FONT.ROM, skye_FONT.ROM, and Portuguese EVO font, checked diffs.
;	Looks like it may be from about 0x86d27 to 0x86f3b.
;	Can't get it to look like a font in yy-chr though... I wonder if that's really it

;What is at segment 62f6? Starts with 5a 00 a0 02 e6 04 2c 07 b2 0a 38 0e be 11 64 14.
