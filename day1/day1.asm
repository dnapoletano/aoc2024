.global _start
.text
.p2align 2

print:
  sub sp, sp, #64
	str	x30, [sp, #16]

  sub sp, sp, #1024
  str x0, [sp]
  adrp x0, messagestr@page
  add x0, x0, messagestr@pageoff

  bl _printf

  add sp, sp, #1024
 	ldr	x30, [sp, #16]
  add sp, sp, #64
  ret


power:
  sub sp, sp, #64
  str	x30, [sp, #16]
.set exponent, 24
  str x0, [sp, exponent]
  mov x0, #1
.set result, 32
  str x0, [sp, result]
  ldr x9, [sp, exponent]
  cmp x9, #0
  b.le exit_power_function

power_loop:
  mov x0, #10
  ldr x1, [sp, result]
  mul x0, x1, x0
  str x0, [sp, result]

  ldr x0, [sp, exponent]

  sub x9, x9, #1
  cmp x9, #0
  b.gt power_loop

exit_power_function:
  ldr x0, [sp, result]

  ldr	x30, [sp, #16]
  add sp, sp, #64
  ret

/// return number (x0) * 10^(x1 - x2)
base_ten_number:
  sub sp, sp, #1024
	str	x30, [sp, #16]

  str x0, [sp, #24]
  str x1, [sp, #32]
  str x2, [sp, #40]

  mov x0, #0
  str x0, [sp, #48]

  sub x0, x1, x2
  bl power  /// 10^(x1 - x2)
  str x0, [sp, #56]
  ldr x1, [sp, #24]
  ldr x2, [sp, #56]

  mul x0, x1, x2
  str x0, [sp, #48]

  ldr x0, [sp, #48]

 	ldr	x30, [sp, #16]
  add sp, sp, #1024
  ret



separator_position:
  sub sp, sp, #1024
	str	x30, [sp, #16]

  str x0, [sp, #24] /// input pointer
  mov x1, #0
  str x1, [sp, #32] /// the position of the separator
find_separator_loop:
  ldr x0, [sp, #24]
  ldr x1, [sp, #32]
  add x0, x1, x0
  ldr x0, [x0]
  and x0, x0, 0xff
  cmp x0, #' '
  b.eq separator_return
  add x1, x1, #1
  str x1, [sp, #32]
  b find_separator_loop

separator_return:
  ldr x0, [sp, #32]

 	ldr	x30, [sp, #16]
  add sp, sp, #1024
  ret


/// x0 null terminated string
/// reads a string of numbers right to left
/// and converts it into an integer value
convert_string_to_int:
  sub sp, sp, #1024
	str	x30, [sp, #16]

.set string, 24
  str x0, [sp, #24]
.set flag, 128
  str x1, [sp, flag]

.set returnvalue, 32
  mov x0, #0
  str x0, [sp, returnvalue]

.set slength, 40
.set index, 48

  ldr x1, [sp, flag]
  cmp x1, #0
  b.eq index_equal_length

index_equal_space:
  ldr x0, [sp, string]
  bl separator_position
  sub x0, x0, #1
  str x0, [sp, slength]
  str x0, [sp, index]

  b start_convert_loop

index_equal_length:
  ldr x0, [sp, string]
  bl _strlen
  sub x0, x0, #2
  str x0, [sp, slength]

  ldr x0, [sp, slength]
  str x0, [sp, index]
  b start_convert_loop


start_convert_loop:
  ldr x6, [sp, index]
convert_loop:
  ldr x0, [sp, string]
  add x2, x0, x6
  ldr x0, [x2]
  and x0, x0, 0xff

  /// empty char, skip
  cmp x0, #'\0'
  b.eq dec_loop
  /// flag signals that the beginning of the string is not the null terminator
  /// but the space
  ldr x1, [sp, flag]
  cmp x1, #0
  b.eq flag_false
  cmp x0, #' '
  b.eq dec_loop


flag_false:
  cmp x0, #' '
  b.eq exit_convert_string_to_int
  cmp x0, #'\n'
  b.eq exit_convert_string_to_int

  cmp x0, 0x30
  b.eq zero
  cmp x0, 0x31
  b.eq one
  cmp x0, 0x32
  b.eq two
  cmp x0, 0x33
  b.eq three
  cmp x0, 0x34
  b.eq four
  cmp x0, 0x35
  b.eq five
  cmp x0, 0x36
  b.eq six
  cmp x0, 0x37
  b.eq seven
  cmp x0, 0x38
  b.eq eight
  cmp x0, 0x39
  b.eq nine

zero:
  mov x0, #0
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
one:
  mov x0, #1
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
two:
  mov x0, #2
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
three:
  mov x0, #3
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
four:
  mov x0, #4
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
five:
  mov x0, #5
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
six:
  mov x0, #6
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
seven:
  mov x0, #7
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
eight:
  mov x0, #8
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop
nine:
  mov x0, #9
  ldr x1, [sp, slength]
  ldr x2, [sp, index]
  bl base_ten_number
  ldr x1, [sp, returnvalue]
  add x0, x0, x1
  str x0, [sp,returnvalue]
  b dec_loop

dec_loop:
  ldr x6, [sp, index]
  sub x6, x6, #1
  str x6, [sp, index]
  cmp x6, #0
  b.ge convert_loop

exit_convert_string_to_int:
  ldr x0, [sp, returnvalue]

 	ldr	x30, [sp, #16]
  add sp, sp, #1024
  ret


split_line:
  sub sp, sp, #1024
	str	x30, [sp, #16]

  str x0, [sp, #24]
  mov x1, #1
  bl convert_string_to_int
  str x0, [sp, #32]

  ldr x0, [sp, #24]
  mov x1, #0
  bl convert_string_to_int
  str x0, [sp, #40]

  ldr x1, [sp, #40]
  ldr x0, [sp, #32]

 	ldr	x30, [sp, #16]
  add sp, sp, #1024
  ret

;;; save ordered inputs:
;;; x0 = base address of vector
;;; x1 = value
;;; x2 = current index
;;; doesn't return, the vector is modified in place
save_ordered_vector:
  sub sp, sp, #1024
	str	x30, [sp, #16]

  str x0, [sp, #24]
  str x1, [sp, #32]
  str x2, [sp, #40]

  ;; mov x0, x1
  ;; bl print
  ;; ldr x2, [sp, #40]
  ;; mov x0, x2
  ;; bl print

  ldr x0, [sp, #24]
  ldr x1, [sp, #32]
  ldr x2, [sp, #40]

;;; if i = 0, then vector[0] = value
  cmp x2, #0
  b.ne check_previous_values
  str x1, [x0]
  b exit_save_ordered_vector

check_previous_values:
  ldr x1, [sp, #40] /// load current index and setup j = i - 1, as starting value
  sub x1, x1, 8
  str x1, [sp, #48]

check_previous_values_loop:
  ldr x1, [sp, #48] /// loads j
  ldr x0, [sp, #24] /// loads base address
  add x0, x0, x1
  ldr x0, [x0]
  ;; and x0, x0, 0xff
  mov x3, x0
  ldr x2, [sp, #32] /// loads value
  cmp x2, x0 /// until x2 is less or equal to x0 or j = 0, move elements of the vector forward and check the next
  b.ge save_current_value
;;; else
;;; take j-th and j+1th elements
;;; x3 contains the jth element
  ldr x0, [sp, #24]
  ldr x1, [sp, #48]
  add x0, x0, x1
  ldr x3, [x0]
  ;; and x3, x3, 0xff
  add x0, x0, #8
  str x3, [x0]                  ; store in j+1


  /// decrease j and continue loop
  ldr x1, [sp, #48]
  sub x1, x1, #8
  str x1, [sp, #48]
  cmp x1, #0
  b.ge check_previous_values_loop


save_current_value:
  ldr x1, [sp, #48]
  add x1, x1, #8
  ldr x0, [sp, #24] /// loads base address
  add x0, x0, x1
  ldr x2, [sp, #32] /// loads value
  str x2, [x0]

exit_save_ordered_vector:
  ldr	x30, [sp, #16]
  add sp, sp, #1024
  ret

;;; x0 contains value from v1
;;; x1 contains base address of v2
;;; x2 contains imax
;;; returns in x0 the number of time the value appears
;;; times the value itself
similarity_score:
  sub sp, sp, #1024
	str	x30, [sp, #16]
;;; as the two vectors are ordered, if the first element
;;; of v2 is > (or if at any point we find a larger value) the value
;;; we want to check, we can return
  str x0, [sp, #24]             ; v1[i]
  str x1, [sp, #32]             ; v2[0]
  str x2, [sp, #40]             ; imax
  mov x2, #0
  str x2, [sp, #48]             ; similarity
  str x2, [sp, #56]             ; counter

find_number_loop:
  ldr x2, [sp, #56]
  ldr x1, [sp, #32]
  add x1, x1, x2
  ldr x1, [x1]
  ldr x0, [sp, #24]
  cmp x0, x1
  b.lt exit_find_number_loop    ; if the value in v2 is greater, exit
  cmp x0, x1                    ; do I have to re-do the check?
  b.ne increase_counter
  ;; else
  ldr x4, [sp, #48]
  add x4, x4, #1
  str x4, [sp, #48]
  b increase_counter


increase_counter:
  ldr x2, [sp, #56]
  add x2, x2, #8
  str x2, [sp, #56]
  ldr x3, [sp, #40]
  cmp x2, x3
  b.lt find_number_loop

exit_find_number_loop:
  ldr x0, [sp, #48]
  ldr x0, [sp, #48]
  ldr x1, [sp, #24]
  mul x0, x0, x1

exit_similarity_score:
  ldr	x30, [sp, #16]
  add sp, sp, #1024
  ret


_start:
;; /// respect the 16 bytes at the beginning of the stack pointer
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
  sub sp, sp, 1024
.set result1, 0                  ;phase-1 result
  mov x0, #0
  str x0, [sp, result1]
.set result2, 8                 ;phase-2 result
  mov x0, #0
  str x0, [sp, result2]

  adrp x0, filename@page
  add x0,  x0, filename@pageoff

  adrp x1, readstring@page
  add x1,  x1, readstring@pageoff


  bl _fopen
.set fileptr, 16
  str x0, [sp, fileptr]
.set buffersize, 512
.set linebufferptr, 24
  mov w0, buffersize
  bl _malloc
  str x0, [sp, linebufferptr]


;;; allocate memory for two vectors of integers
;;; I set the max memory to be 2000 * sizeof(size_t) (=8) = 16000
;;; as usually the input lines is about 1000, so I'm doubling it.
.set maxmemory, 16000
.set vector1, 32
.set vector2, 40
  mov x0, maxmemory
  bl _malloc
  str x0, [sp, vector1]
  mov x0, maxmemory
  bl _malloc
  str x0, [sp, vector2]

.set index_i, 48
.set imax, 56
  mov x0, #0
  str x0, [sp, index_i]
  str x0, [sp, imax]
loop:
  ldr x0, [sp, linebufferptr]
  mov x1, buffersize

  ldr x2, [sp, fileptr]
  bl _fgets
  /// check that read was possible
  cmp x0, 0x00
  b.eq play_with_vector ///exitloop

/// read line and convert
  ldr x0, [sp, linebufferptr]
  bl split_line
testlabel:
  mov x22, x0
  mov x23, x1

  ldr x0, [sp, vector1]
  mov x1, x22
  ldr x2, [sp, index_i]

  bl save_ordered_vector

  ldr x0, [sp, vector2]
  mov x1, x23
  ldr x2, [sp, index_i]

  bl save_ordered_vector

  ldr x1, [sp, index_i]
  add x1, x1, #8
  str x1, [sp, index_i]
  str x1, [sp, imax]

  b loop

play_with_vector:
  mov x0, #0
  str x0, [sp, index_i]
play_with_vector_loop:
  ;;  compute result for phase-1
  ldr x1, [sp, index_i]
  ldr x0, [sp, vector1]
  add x0, x0, x1
  ldr x0, [x0]                  ; v1[i]
  ldr x2, [sp, vector2]
  add x2, x2, x1
  ldr x2, [x2]                  ; v2[i]
  cmp x0, x2
  b.ge sub_a_b
  b sub_b_a

sub_a_b:
  sub x3, x0, x2
  b sum_distance

sub_b_a:
  sub x3, x2, x0
  b sum_distance

sum_distance:
  ldr x0, [sp, result1]
  add x0, x0, x3
  str x0, [sp, result1]

  ;; compute result for phase-2
  ldr x1, [sp, index_i]
  ldr x0, [sp, vector1]
  add x0, x0, x1
  ldr x0, [x0]                  ; v1[i]
  ldr x1, [sp, vector2]
  ldr x2, [sp, imax]
  bl similarity_score

  ldr x2, [sp, result2]
  add x0, x0, x2
  str x0, [sp, result2]

  ldr x1, [sp, index_i]
  add x1, x1, #8
  str x1, [sp, index_i]

  ldr x2, [sp, imax]
  cmp x1, x2
  b.lt play_with_vector_loop


exitloop:
  ldr x0, [sp, result1]
  bl print
  ldr x0, [sp, result2]
  bl print
exit:
  ldr x0, [sp, fileptr]
  bl _fclose

  add sp, sp, #1024
	/// load original sp address from x28

  /// return stack to original position
  ldp	x29, x30, [sp, #16]
	add	sp, sp, #32

  mov x0, #0
  bl _exit

/// data section, here I store heap variables
.data
filename: .asciz "./input.txt"
messagestr: .asciz "y = %d\n"
message3str: .asciz "%d, %d \n"
readstring: .asciz "r"
newlinestring: .asciz "\n"
