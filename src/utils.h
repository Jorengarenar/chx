/* SPDX-License-Identifier:  MIT
 * Copyright 2021 nicholascok
 * Copyright 2023 Jorengarenar
 */

#ifndef UTILS_H_
#define UTILS_H_

#include <stdint.h>
#include <stddef.h>

#include <ansi_esc_seq.h>

#define cur_set(X, Y) printf(ANSI_CUP(%d,%d), Y + 1, X + 1)

#define IS_PRINTABLE(C) (C > 0x1F && C < 0x7F)
#define IS_LETTER(C)    ((C ^ 0x40) < 26 || (C ^ 0x60) < 26)
#define IS_CHAR_HEX(C)  ((C ^ 0x40) < 7 || (C ^ 0x60) < 7 || (C ^ 0x30) < 10)
#define IS_DIGIT(C)     ((C ^ 0x30) < 10)
#define IS_QUOTATION(C) (C == '\'' || C == '"')

#define WORD(X) *((uint16_t*) &X)

long chx_abs(long _n);
long min(long _a, long _b);
long max(long _a, long _b);
char* memfork(char* _p, int _l);
char* recalloc(char* _p, long _o, long _n);
int chx_count_digits(long _n);
char str_is_num(char* _s);
char str_is_hex(char* _s);
int str_to_num(char* _s);
long str_to_hex(char* _s);
int str_len(char* _s);
char cmp_str(char* _a, char* _b);
char* chx_extract_param(char* _s, int _n);

#endif // UTILS_H_
