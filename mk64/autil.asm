extern interrupt$kb_handler
extern io$vidptr

global interrupt$inb
global interrupt$outb
global interrupt$keyboard_w
global interrupt$generic_handler

interrupt$generic_handler: iretq

interrupt$keyboard_w:
  ; I put this here for testing while I figured out what's wrong
  ; it should *technically* call interrupt$kb_handler
  mov byte [io$vidptr], '!'
  mov byte [io$vidptr+1], '!'
  mov byte [io$vidptr+2], '!'
  mov byte [io$vidptr+3], '!'
  t: jmp t
  ;call interrupt$kb_handler
  iretq

interrupt$inb:
  mov dx, [rsp+4]
  in al, dx
  ret

interrupt$outb:
  mov dx, [rsp+4]
  mov al, [rsp+6]
  out dx, al
  ret
