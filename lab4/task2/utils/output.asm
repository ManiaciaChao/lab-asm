;change ss
switch_stack proc far uses ax si
obfs_89 label far
    cmp cs:current_stack, 0
    jne cs1
jmp far ptr obfs_90
obfs_98 label far
  switch_done:
    ; assign ss to next stack
    mov ax, es
jmp far ptr obfs_99
obfs_97 label far
    jne switch_loop
jmp far ptr obfs_98
obfs_92 label far
  cs1:
    mov cs:current_stack, 0
    mov ax, stack
jmp far ptr obfs_93
obfs_93 label far
  switch_start:
    mov es, ax; assign es to next stack
jmp far ptr obfs_94
obfs_99 label far
    mov ss, ax
jmp far ptr obfs_100
obfs_100 label far
    ret
obfs_90 label far
  cs0:
    mov cs:current_stack, 1
    mov ax, stackbak
jmp far ptr obfs_91
obfs_95 label far
  switch_loop:; copy from top to sp
    dec si
jmp far ptr obfs_96
obfs_96 label far
    ; copy from ss to es
    mov ah, ss:[si]
    mov es:[si], ah
    cmp si, sp; stop until reach top
jmp far ptr obfs_97
obfs_94 label far
    mov si, stack_size+1;
jmp far ptr obfs_95
obfs_91 label far
    jmp switch_start
jmp far ptr obfs_92
switch_stack endp
; change al, where saves 2 BCD-digit
get_sec proc far
obfs_101 label far
    mov al, 0
jmp far ptr obfs_102
obfs_103 label far
    jmp $+2
jmp far ptr obfs_104
obfs_104 label far
    in al, 71h; now al is two BCD
jmp far ptr obfs_105
obfs_102 label far
    out 70h, al
jmp far ptr obfs_103
obfs_105 label far
    ret
get_sec endp 
new08h proc far
obfs_106 label far
    pushf
jmp far ptr obfs_107
obfs_108 label far
  switch:
    mov cs:count, 18 
    sti
jmp far ptr obfs_109
obfs_112 label far
    pusha
jmp far ptr obfs_113
obfs_109 label far
    call far ptr get_sec
jmp far ptr obfs_110
obfs_115 label far
  int_ret:
    iret
obfs_111 label far
    jne int_ret
jmp far ptr obfs_112
obfs_107 label far
    call dword ptr cs:origin_int
    dec cs:count
    jnz int_ret
jmp far ptr obfs_108
obfs_114 label far
    popa
jmp far ptr obfs_115
obfs_113 label far
    call far ptr switch_stack
jmp far ptr obfs_114
obfs_110 label far
    cmp al, 00110000b
jmp far ptr obfs_111
new08h endp
reg_int proc far uses ax bx dx ds es
obfs_116 label far
    push cs; ds cs
jmp far ptr obfs_117
obfs_124 label far
    int 21h
jmp far ptr obfs_125
obfs_122 label far
    mov dx, offset new08h
jmp far ptr obfs_123
obfs_119 label far
    int 21h
jmp far ptr obfs_120
obfs_120 label far
    mov origin_int, bx
jmp far ptr obfs_121
obfs_125 label far
    mov int_installed, 1
jmp far ptr obfs_126
obfs_126 label far
    ret
obfs_123 label far
    mov ax, 2508h
jmp far ptr obfs_124
obfs_117 label far
    pop ds; ds
jmp far ptr obfs_118
obfs_121 label far
    mov origin_int+2,es
jmp far ptr obfs_122
obfs_118 label far
    mov ax, 3508h
jmp far ptr obfs_119
reg_int endp
rm_int proc far uses ax dx
obfs_127 label far
    lds dx, dword ptr cs:origin_int
    mov ax, 2508h
jmp far ptr obfs_128
obfs_128 label far
    int 21h
jmp far ptr obfs_129
obfs_129 label far
    ret
rm_int endp
init_int proc far
obfs_130 label far
    cmp cs:int_installed, 1
    je c7
jmp far ptr obfs_131
obfs_132 label far
    c7:; already installed
    ret
obfs_131 label far
    call far ptr reg_int
jmp far ptr obfs_132
init_int endp
; optimized
calc_rec_o proc far
obfs_133 label far
    ; push ax
    ; push bx
    ; push cx
    ; push dx
    mov ax, goods[di].cost
jmp far ptr obfs_134
obfs_147 label far
    mov ax, goods[di].sv; ax=sv
jmp far ptr obfs_148
obfs_141 label far
    div bx
jmp far ptr obfs_142
obfs_148 label far
    shl ax, 6; ax <<6 /2
jmp far ptr obfs_149
obfs_151 label far
    add ax, si; ax=cost*128/real_price +sv*128/(wv*2)
jmp far ptr obfs_152
obfs_139 label far
    mul goods[di].discount
jmp far ptr obfs_140
obfs_150 label far
    div goods[di].wv; ax=sv*128/wv
jmp far ptr obfs_151
obfs_134 label far
    xor ax, key
jmp far ptr obfs_135
obfs_135 label far
    shl ax, 7; ax=cost*128
jmp far ptr obfs_136
obfs_138 label far
    xor dx,dx
jmp far ptr obfs_139
obfs_140 label far
    mov bx,10
jmp far ptr obfs_141
obfs_142 label far
    mov bx, ax; bx=price*discount/10=real_price
jmp far ptr obfs_143
obfs_145 label far
    div bx; ax=cost*128/real_price
jmp far ptr obfs_146
obfs_153 label far
    ; pop ax
    ; pop bx
    ; pop cx
    ; pop dx
    ret
obfs_144 label far
    xor dx,dx
jmp far ptr obfs_145
obfs_136 label far
    push ax
jmp far ptr obfs_137
obfs_137 label far
    mov ax, goods[di].price
jmp far ptr obfs_138
obfs_149 label far
    xor dx, dx
jmp far ptr obfs_150
obfs_143 label far
    pop ax; ax=cost*128
jmp far ptr obfs_144
obfs_152 label far
    mov word ptr goods[di].rec, ax
jmp far ptr obfs_153
obfs_146 label far
    mov si, ax; cx=cost*128/real_price
jmp far ptr obfs_147
calc_rec_o endp
login proc far
obfs_154 label far
    ; get input
    @log msg_login_username
jmp far ptr obfs_155
obfs_177 label far
    jmp xor_pw
jmp far ptr obfs_178
obfs_169 label far
    mov bl, byte ptr [di]
jmp far ptr obfs_170
obfs_180 label far
    call get_sec;
jmp far ptr obfs_181
obfs_185 label far
    cmp ax,0
jmp far ptr obfs_186
obfs_179 label far
    mov ah,al
jmp far ptr obfs_180
obfs_158 label far
    @gets state_password_meta,16,'$'
jmp far ptr obfs_159
obfs_165 label far
    push ax
jmp far ptr obfs_166
obfs_161 label far
    ; check username
    @strcmp state_username, config_username
jmp far ptr obfs_162
obfs_193 label far
    ret
obfs_170 label far
    xor bh, bl
jmp far ptr obfs_171
obfs_171 label far
    mov [di], bh
jmp far ptr obfs_172
obfs_172 label far
    inc si
jmp far ptr obfs_173
obfs_173 label far
    inc di
jmp far ptr obfs_174
obfs_188 label far
    mov byte ptr[state_auth], 1
jmp far ptr obfs_189
obfs_155 label far
    @gets state_username_meta,16,'$'
jmp far ptr obfs_156
obfs_166 label far
  start_xor:
    lea si, config_username
jmp far ptr obfs_167
obfs_176 label far
    je cmp_pw
jmp far ptr obfs_177
obfs_174 label far
    mov bl, [si]
jmp far ptr obfs_175
obfs_167 label far
    lea di, state_password
jmp far ptr obfs_168
obfs_164 label far
    ; check password    mov di, state_select_good
    call get_sec;
jmp far ptr obfs_165
obfs_182 label far
    cmp ah, 2
jmp far ptr obfs_183
obfs_163 label far
    jnz login_rej
jmp far ptr obfs_164
obfs_189 label far
    @logln msg_menu_hr
jmp far ptr obfs_190
obfs_187 label far
    @logln msg_login_resolved
jmp far ptr obfs_188
obfs_168 label far
  xor_pw:
    mov bh, byte ptr [si]
jmp far ptr obfs_169
obfs_178 label far
  cmp_pw:
    pop ax
jmp far ptr obfs_179
obfs_175 label far
    cmp bl, '$'
jmp far ptr obfs_176
obfs_183 label far
    je login_rej
jmp far ptr obfs_184
obfs_190 label far
    ret
jmp far ptr obfs_191
obfs_192 label far
    @logln msg_login_rejected
jmp far ptr obfs_193
obfs_181 label far
    sub ah,al
jmp far ptr obfs_182
obfs_184 label far
    @strcmp state_password, config_password
jmp far ptr obfs_185
obfs_156 label far
    @breakline
jmp far ptr obfs_157
obfs_191 label far
  login_rej:
    mov byte ptr[state_auth], 0
jmp far ptr obfs_192
obfs_159 label far
    @breakline
jmp far ptr obfs_160
obfs_160 label far
    @cls
jmp far ptr obfs_161
obfs_157 label far
    @log msg_login_password
jmp far ptr obfs_158
obfs_186 label far
    jnz login_rej
jmp far ptr obfs_187
obfs_162 label far
    cmp ax,0
jmp far ptr obfs_163
login endp
query proc far
obfs_194 label far
    mov cx, [goods_types]
jmp far ptr obfs_195
obfs_195 label far
    mov di,0
jmp far ptr obfs_196
obfs_202 label far
    add di, type Good
jmp far ptr obfs_203
obfs_205 label far
  query_resolved:
    mov word ptr[state_select_good], di
jmp far ptr obfs_206
obfs_197 label far
    @gets state_goodname_meta,10,'$'
jmp far ptr obfs_198
obfs_207 label far
    ret
obfs_198 label far
    @breakline
jmp far ptr obfs_199
obfs_204 label far
    ret
jmp far ptr obfs_205
obfs_196 label far
    @log msg_query_name
jmp far ptr obfs_197
obfs_203 label far
    loop query_loop
jmp far ptr obfs_204
obfs_201 label far
    jz query_resolved
jmp far ptr obfs_202
obfs_200 label far
    cmp ax,0
jmp far ptr obfs_201
obfs_206 label far
    call info
jmp far ptr obfs_207
obfs_199 label far
  query_loop:
    @strcmp state_goodname, goods[di].gname
jmp far ptr obfs_200
query endp
info proc far
obfs_208 label far
    mov di, state_select_good
jmp far ptr obfs_209
obfs_221 label far
    @log msg_query_info_rec
jmp far ptr obfs_222
obfs_218 label far
    @log msg_query_info_sv
jmp far ptr obfs_219
obfs_220 label far
    @breakline
jmp far ptr obfs_221
obfs_222 label far
    @dump goods[di].rec, 1, 2
jmp far ptr obfs_223
obfs_216 label far
    @dump goods[di].wv, 1, 2
jmp far ptr obfs_217
obfs_212 label far
    ; @log msg_query_info_cost
    ; @dump goods[di].cost, 1, 2
    ; @breakline
    @log msg_query_info_price
jmp far ptr obfs_213
obfs_224 label far
    @logln msg_menu_hr
jmp far ptr obfs_225
obfs_223 label far
    @breakline
jmp far ptr obfs_224
obfs_209 label far
    ; @dump goods[di].gname, 1, 2
    ; @breakline
    @log msg_query_info_discount
jmp far ptr obfs_210
obfs_211 label far
    @breakline
jmp far ptr obfs_212
obfs_225 label far
    ret
obfs_215 label far
    @log msg_query_info_wv
jmp far ptr obfs_216
obfs_219 label far
    @dump goods[di].sv, 1, 2
jmp far ptr obfs_220
obfs_214 label far
    @breakline
jmp far ptr obfs_215
obfs_217 label far
    @breakline
jmp far ptr obfs_218
obfs_213 label far
    @dump goods[di].price, 1, 2
jmp far ptr obfs_214
obfs_210 label far
    @dump goods[di].discount, 1, 1
jmp far ptr obfs_211
info endp
order proc far
obfs_226 label far
    cmp state_select_good, -1
jmp far ptr obfs_227
obfs_239 label far
    add di, type Good
jmp far ptr obfs_240
obfs_235 label far
    mov cx, [goods_types]
jmp far ptr obfs_236
obfs_243 label far
    @logln msg_menu_hr
jmp far ptr obfs_244
obfs_246 label far
    @logln msg_menu_hr
jmp far ptr obfs_247
obfs_233 label far
    @logln msg_order_done
jmp far ptr obfs_234
obfs_242 label far
  order_rejected_stock:
    @logln msg_order_err_stock
jmp far ptr obfs_243
obfs_231 label far
    jle order_rejected_stock
jmp far ptr obfs_232
obfs_227 label far
    jz order_rejected_emtpy
jmp far ptr obfs_228
obfs_230 label far
    sub cx, goods[di].sv
jmp far ptr obfs_231
obfs_237 label far
    xor di, di
jmp far ptr obfs_238
obfs_245 label far
  order_rejected_emtpy:
    @logln msg_order_err_empty
jmp far ptr obfs_246
obfs_234 label far
    @logln msg_menu_hr
jmp far ptr obfs_235
obfs_241 label far
    ret
jmp far ptr obfs_242
obfs_244 label far
    ret
jmp far ptr obfs_245
obfs_240 label far
    loop recommend_loop
jmp far ptr obfs_241
obfs_238 label far
  recommend_loop:
    call calc_rec_o
jmp far ptr obfs_239
obfs_247 label far
    ret
obfs_229 label far
    mov cx, goods[di].wv
jmp far ptr obfs_230
obfs_228 label far
    mov di, state_select_good
jmp far ptr obfs_229
obfs_236 label far
    sub cx, 1
jmp far ptr obfs_237
obfs_232 label far
    add word ptr goods[di].sv,1
jmp far ptr obfs_233
order endp
modify proc far
obfs_248 label far
    cmp state_auth, 0
jmp far ptr obfs_249
obfs_254 label far
    @mutate goods[di].discount, 1,1
jmp far ptr obfs_255
obfs_250 label far
    cmp state_select_good, -1
jmp far ptr obfs_251
obfs_258 label far
    @mutate goods[di].price, 1,2
jmp far ptr obfs_259
obfs_252 label far
  ; 折扣，进货价，销售价，进货总数
    mov di, state_select_good
jmp far ptr obfs_253
obfs_255 label far
    @log msg_query_info_cost
jmp far ptr obfs_256
obfs_257 label far
    @log msg_query_info_price
jmp far ptr obfs_258
obfs_256 label far
    @mutate_xor goods[di].cost, 1,2
jmp far ptr obfs_257
obfs_253 label far
    @log msg_query_info_discount
jmp far ptr obfs_254
obfs_260 label far
    @mutate goods[di].wv,1, 2
jmp far ptr obfs_261
obfs_261 label far
    ret
obfs_251 label far
    jz menu
jmp far ptr obfs_252
obfs_259 label far
    @log msg_query_info_wv
jmp far ptr obfs_260
obfs_249 label far
    jz menu
jmp far ptr obfs_250
modify endp
; read state_edit_buf, change ax
vaild_num proc far uses ax cx si di
obfs_262 label far
    lea di, state_edit_meta+1
jmp far ptr obfs_263
obfs_286 label far
  blank:
    mov bx, -2
jmp far ptr obfs_287
obfs_285 label far
    ret
jmp far ptr obfs_286
obfs_264 label far
    cmp cx, 0
jmp far ptr obfs_265
obfs_275 label far
    ja err
jmp far ptr obfs_276
obfs_287 label far
    ret
jmp far ptr obfs_288
obfs_276 label far
    sub al, '0'; now ax=digit
jmp far ptr obfs_277
obfs_278 label far
    je vl4 ; skip
jmp far ptr obfs_279
obfs_288 label far
  err: ; NaN
    mov bx, -1
jmp far ptr obfs_289
obfs_284 label far
    mov ax, 1
jmp far ptr obfs_285
obfs_282 label far
    inc si
jmp far ptr obfs_283
obfs_265 label far
    je blank
jmp far ptr obfs_266
obfs_272 label far
    cmp al,'0'
jmp far ptr obfs_273
obfs_270 label far
    add di, cx
jmp far ptr obfs_271
obfs_274 label far
    cmp al,'9'
jmp far ptr obfs_275
obfs_280 label far
    pop cx
jmp far ptr obfs_281
obfs_263 label far
    movzx cx, byte ptr [di];size
jmp far ptr obfs_264
obfs_267 label far
    xor ax,ax
jmp far ptr obfs_268
obfs_281 label far
  vl4: ; isDigit
    add bx, ax
jmp far ptr obfs_282
obfs_266 label far
    xor si,si; si=0
jmp far ptr obfs_267
obfs_269 label far
  vl1:
    lea di, state_edit_meta+1
jmp far ptr obfs_270
obfs_271 label far
    mov al, [di];
jmp far ptr obfs_272
obfs_279 label far
    push cx
jmp far ptr obfs_280
obfs_268 label far
    xor bx,bx
jmp far ptr obfs_269
obfs_273 label far
    jb err
jmp far ptr obfs_274
obfs_289 label far
    ret
obfs_277 label far
  vl2:
    cmp si, 0
jmp far ptr obfs_278
obfs_283 label far
    loop vl1
jmp far ptr obfs_284
vaild_num endp
mutate proc far
obfs_290 label far
  m_start:
    @gets state_edit_meta,16,'$'
jmp far ptr obfs_291
obfs_295 label far
    @breakline
jmp far ptr obfs_296
obfs_297 label far
    mov [si], bx
jmp far ptr obfs_298
obfs_294 label far
    cmp bx, -1 
jmp far ptr obfs_295
obfs_293 label far
    je m_exit
jmp far ptr obfs_294
obfs_298 label far
  m_exit:
    ret
obfs_292 label far
    cmp bx, -2 
jmp far ptr obfs_293
obfs_296 label far
    je m_start
jmp far ptr obfs_297
obfs_291 label far
    call far ptr vaild_num; bx
jmp far ptr obfs_292
mutate endp
mutate_xor proc far
obfs_299 label far
  mx_start:
    @gets state_edit_meta,16,'$'
jmp far ptr obfs_300
obfs_307 label far
    mov [si], bx
jmp far ptr obfs_308
obfs_304 label far
    @breakline
jmp far ptr obfs_305
obfs_300 label far
    call far ptr vaild_num; bx
jmp far ptr obfs_301
obfs_305 label far
    je m_start
jmp far ptr obfs_306
obfs_301 label far
    cmp bx, -2 
jmp far ptr obfs_302
obfs_302 label far
    je m_exit
jmp far ptr obfs_303
obfs_308 label far
  mx_exit:
    ret
obfs_303 label far
    cmp bx, -1 
jmp far ptr obfs_304
obfs_306 label far
    xor bx, key
jmp far ptr obfs_307
mutate_xor endp
