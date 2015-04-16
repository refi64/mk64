; just dummy wrappers for Myrddin's rt library

global _rt$abort_oob
extern io$vidptr

_rt$abort_oob:
  mov byte [io$vidptr], 'O'
  mov byte [io$vidptr+2], 'O'
  mov byte [io$vidptr+4], 'B'
  mov byte [io$vidptr+6], '!'
  inf: jmp inf
