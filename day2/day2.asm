.global _start
.text
.p2align 2

;;; utility functions
.macro test_print
;;; move x0-x7 to temp registers 19-27, print and back
  mov x27, x0
  mov x26, x1
  mov x25, x2
  mov x24, x3
  mov x23, x4
  mov x22, x5
  mov x21, x6
  mov x20, x7
  /// call print with whatever was in x0
  bl print
  /// restore registers
  mov x0, x27
  mov x1, x26
  mov x2, x25
  mov x3, x24
  mov x4, x23
  mov x5, x22
  mov x6, x21
  mov x7, x20
.endm


;;; wrapper around printf with a preset message string
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

;;; compute the integer power of an integer number
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

/// returns number (x0) * 10^(x1 - x2)
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


;;; find the position of the character ' ' in a string
;;; which is used to split the string
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
/// and converts it into an unsigned integer value
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
  /// but the space, this is used to read multiple numbers from a given line
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

;;; reads a line and fills a vector with the converted numbers
split_line:
  sub sp, sp, #1024
	str	x30, [sp, #16]

  .set input_line, 24
  str x0, [sp, input_line]

  .set previous_number, 32
  .set current_number, 40
  .set sl_index_i, 48
  .set sl_index_current, 56
  .set sl_result, 64
  mov x0, #0
  str x0, [sp, previous_number]
  str x0, [sp, current_number]
  str x0, [sp, sl_index_i]
  str x0, [sp, sl_index_current]
  str x0, [sp, sl_result]

  .set temp_buffer_size, 5
  .set temp_buffer, 72
  mov x0, temp_buffer_size
  bl _malloc
  str x0, [sp, temp_buffer]

  .set number_of_numbers, 80
  mov x0, #0
  str x0, [sp, number_of_numbers]

  .set current_status, 88
  mov x0, #0
  str x0, [sp, current_status]
  .set previous_status, 96
  mov x0, #1
  str x0, [sp, previous_status]

split_line_loop:
  ldr x1, [sp, sl_index_i]
  ldr x0, [sp, input_line]
  add x0, x0, x1
  ldr x0, [x0]
  and x0, x0, 0xff
  cmp x0, #' '
;;; if current char == ' ' means I finished reading
;;; a number and should evaluate it and compare it
;;; otherwise it can either be an end of line char
;;; or a numeric char which I need to add to the
;;; current vector
  b.eq store_current_number
  cmp x0, #'\n'
  b.eq store_last_number

  ldr x2, [sp, temp_buffer]
  ldr x3, [sp, sl_index_current]
  add x2, x2, x3
  str x0, [x2]

  add x3, x3, #1
  str x3, [sp, sl_index_current]
  b increase_counter_and_continue

store_current_number:
  ldr x2, [sp, temp_buffer]
  ldr x3, [sp, sl_index_current]
  add x2, x2, x3
  mov x0, #'\0'
  str x0, [x2]
  mov x0, #0
  str x0, [sp, sl_index_current]

  ldr x0, [sp, temp_buffer]
  mov x1, #0
  bl convert_string_to_int
  str x0, [sp, current_number]
  ldr x1, [sp, number_of_numbers]
  cmp x1, #0
  b.ne compare_current_and_previous
;;; if this is the first number we read
;;; then previous = current, otherwise compare
;;; previous and current
  ldr x1, [sp, number_of_numbers]
  cmp x1, #10
  b.eq end_split_line_loop

  add x1, x1, #1
  str x1, [sp, number_of_numbers]
  b increase_counter_and_continue

compare_current_and_previous:
  ldr x0, [sp, current_number]
  ldr x1, [sp, previous_number]
  /// temp = cur - bcur
  sub x2, x0, x1
  mov x0, x2

  str x2, [sp, current_status]
  cmp x2, #0
  b.eq not_ordered
  cmp x2, #0
  b.lt compare_negative
  b compare_positive

compare_negative:
  add x3, x2, #3
  cmp x3, #0
  b.lt not_ordered
  b maybe_ordered

compare_positive:
  sub x3, x2, #3
  cmp x3, #0
  b.gt not_ordered
  b maybe_ordered

maybe_ordered:
  ldr x4, [sp, number_of_numbers]
  cmp x4, #1
  b.gt subsequent_steps

first_step:
  ldrsw x0, [sp, current_status]
  str x0, [sp, previous_status]
  b post_comparison

subsequent_steps:
  ldrsw x0, [sp, current_status]
  ldrsw x1, [sp, previous_status]
  mul x0, x0, x1
  cmp x0, #0
  b.lt not_ordered
  mov x0, #1
  str x0, [sp, sl_result]

post_comparison:
  ldr x1, [sp, number_of_numbers]
  cmp x1, #10
  b.eq end_split_line_loop
  add x1, x1, #1
  str x1, [sp, number_of_numbers]

increase_counter_and_continue:
  ldr x0, [sp, current_number]
  str x0, [sp, previous_number]

  ldr x1, [sp, sl_index_i]
  add x1, x1, #1
  str x1, [sp, sl_index_i]
  b split_line_loop

store_last_number:
  mov x0, #10
  str x0, [sp, number_of_numbers]

  b store_current_number

not_ordered:
  mov x0, #0
  str x0, [sp, sl_result]

end_split_line_loop:
  ldr x0, [sp, sl_result]
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

loop:
  ldr x0, [sp, linebufferptr]
  mov x1, buffersize

  ldr x2, [sp, fileptr]
  bl _fgets
  /// check that read was possible
  cmp x0, 0x00
  b.eq exitloop ///exitloop and move on

/// read line and convert
  ldr x0, [sp, linebufferptr]

  bl split_line
  ;; test_print
  ldr x1, [sp, result1]
  add x0, x0, x1
  str x0, [sp, result1]
  b loop


exitloop:
  ldr x0, [sp, result1]
  bl print
  ;; ldr x0, [sp, result2]
  ;; bl print
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
