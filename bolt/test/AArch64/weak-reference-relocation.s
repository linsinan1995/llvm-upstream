// This test checks that the gold linker style veneer are properly handled
// by BOLT.
// Strip .rela.mytext section to simulate inserted by a linker veneers
// that does not contain relocations.

# RUN: %clang -Wl,-q -nostartfiles %s -o %t.exe
# RUN: llvm-bolt %t.exe -o %t.bolt
# RUN: obj2yaml %t.bolt | FileCheck %s

CHECK:  - Name:            .rodata
CHECK-NEXT:    Type:            SHT_PROGBITS
CHECK-NEXT:    Flags:           [ SHF_ALLOC ]
CHECK-NEXT:    Address:         0x{{0*}}
CHECK-NEXT:    AddressAlign:    0x{{0*}}
CHECK-NEXT:    Content:         '{{0+}}'

        .arch armv8-a
        .text
        .align  2
        .global _start
        .type   _start, %function
_start:
.LFB6:
        .cfi_startproc
        stp     x29, x30, [sp, -16]!
        .cfi_def_cfa_offset 16
        .cfi_offset 29, -16
        .cfi_offset 30, -8
        mov     x29, sp
        adrp    x0, .LC0
        add     x0, x0, :lo12:.LC0
        ldr     x0, [x0]
        cmp     x0, 0
        beq     .L2
        bl      func
.L2:
        mov     w0, 0
        bl      exit
        .cfi_endproc
.LFE6:
        .size   _start, .-_start
        .section        .rodata
        .align  3
.LC0:
        .xword  func
        .weak   func
        .section        .note.GNU-stack,"",@progbits
