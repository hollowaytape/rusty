; Hack for displaying halfwidth text in STORY/ENEMY.COM files.
; First successful text hack for this game.

JO.EXE HALFWIDTH TEXT HACK:
;change the value at 0x20193 from 04 to 02 (19fb:61e3?) 0x5b97 0x5f96???
;If I change this 46 (19fb:61b4), or 5f68 in JO.EXE, to a 90 (nop), it'll read every letter at least.

;How I arrived at that conclusion:
;STORY2.COM stuff

;Displays halfwidth characters right away, but only displays every other character. "Hello there!" -> "H l o t e e "

;The game reads the pointer [si], which has the value 3920 - and text begins at offset 3920 in STORY2.COM, loads it into al, and does some stuff

;There's an "inc si" (46) instruction shortly after this. This sets it to 3921. But it never reads the value at 3921, it just skips to 3922 the next time it loads that value.

;If I change this 46 (19fb:61b4), or 5f68 in JO.EXE, to a 90 (nop), it'll read every letter at least. It still spaces em out of course, and it reads twice as many characters as it should, so it loops around the screen! (And spits out garbage when there are fullwidth characters, but who cares about that)

;SPACES
;Fullwidth chars are 32x32, halfwidth chars are 16x32. So, look for anything increasing by 0x20 after a SJIS space?
1374:291e b020 mov al, 20 ;?
1374:2904 b020 mov al, 20 ;?

;COMPARING MEMORY AFTER EACH FULLWIDTH CHARACTER IS PRINTED
;Dead ends/stuff that didn't change every time:
;13e70: 89 30 00 f6 60 ff 4d -> 7a 2d 32 00 00 00 01
;13e7a: 00 ff -> 02 13
;17274: 19 -> 32
;1727a: 00 00 3b -> 95 8f bb -> 00 00 bb
;1727e: 95 02 60 00 bc 0e 23 -> bb 00 00 07 02 72 34
;1728a: 14 -> 18
;1728e: 22 05 -> 95 8f -> 00 00
;1a8a2: c6 06 -> 7e 47

;Better leads:
;168f3: 23 -> 28 -> 2d -> 31 (this increments normally, probably a frame counter.)
;1728c: 90 -> 92 -> 94 -> 96 (appears to be a byte pointer for reading the string?)
;1b61d: 06 -> 0b -> 10 -> 15 (not looking at this one, there are loops that check it over and over)

;Best lead:
;!17292: 08 -> 0c -> 10 -> 14 (appears to be position in a line! multiply by 8 to get onscreen horizontal coord)
;Using a bunch of 8140 spaces (Save 2), trying to see if I can figure out what data is getting moved here.
;Nohting ever reads this address, so can't use a breakpoint.
;Takes about 8-11 seconds of "next instruction" to get it to change the first time.
;ECX has the value 0x0c in there while the memory address is still 0x08. Probably loads it into there.
;19fb:61e1 83c104 add cx, +04
;Unfortunately this is right after a branch that's just for the 8140 space... but let's see what it does.
;change the value at 0x20193 from 04 to 02
;This squishes the Japanese text!! Let's try the halfwidth text.
;It works too!!

19fb: 61eb 83c102 add cx, +02
19fb:61ee 83c210 add dx, +10   ;(this looks like it's meant for halfwidth characters!)

;STORY.COM POINTERS
;Hard-coded into the functions
;60 1e 06 8c c8 8e d8 b3 xx yy b9
;60 1e 06 8c c8 8e d8 be xx yy b9
;60 1e 06 8c c8 8e d8 be 4a 33 b9

;another pointer is like this:
;                  53 0f 9d_33 51