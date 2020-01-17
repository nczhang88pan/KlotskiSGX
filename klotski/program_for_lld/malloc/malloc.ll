; ModuleID = 'malloc.c'
source_filename = "malloc.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.malloc_params = type { i64, i64, i64, i64, i64, i32 }
%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.malloc_state = type { i32, i32, i64, i64, i8*, %struct.malloc_chunk*, %struct.malloc_chunk*, i64, i64, i64, [66 x %struct.malloc_chunk*], [32 x %struct.malloc_tree_chunk*], i64, i64, i64, i32, %struct.malloc_segment, i8*, i64 }
%struct.malloc_chunk = type { i64, i64, %struct.malloc_chunk*, %struct.malloc_chunk* }
%struct.malloc_tree_chunk = type { i64, i64, %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk*, [2 x %struct.malloc_tree_chunk*], %struct.malloc_tree_chunk*, i32 }
%struct.malloc_segment = type { i8*, i64, %struct.malloc_segment*, i32 }
%struct.mallinfo = type { i64, i64, i64, i64, i64, i64, i64, i64, i64, i64 }

@.str = private unnamed_addr constant [25 x i8] c"Heap space is not enough\00", align 1
@mparams = internal global %struct.malloc_params zeroinitializer, align 8
@_heap = internal global i8* getelementptr inbounds ([8388608 x i8], [8388608 x i8]* @_heap_chk0, i64 0, i64 0), align 8
@_ms = internal global i8* null, align 8
@stderr = external global %struct._IO_FILE*, align 8
@.str.1 = private unnamed_addr constant [26 x i8] c"max system bytes = %10lu\0A\00", align 1
@.str.2 = private unnamed_addr constant [26 x i8] c"system bytes     = %10lu\0A\00", align 1
@.str.3 = private unnamed_addr constant [26 x i8] c"in use bytes     = %10lu\0A\00", align 1
@_heap_chk0 = internal global [8388608 x i8] zeroinitializer, align 16

; Function Attrs: nounwind uwtable
define noalias i8* @morecore() local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 (...)* @puts to i64*)) #7
  %1 = bitcast i64* %0 to i32 (...)*
  %2 = bitcast i32 (...)* %1 to i32 (i8*, ...)*
  %call = tail call i32 (i8*, ...) %2(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str, i64 0, i64 0)) #7
  ret i8* null
}

declare i32 @puts(...) #1

; Function Attrs: nounwind uwtable
define noalias i8* @create_mspace(i64 %capacity, i32 %locked) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (%struct.malloc_state* (i8*, i64)* @init_user_mstate to i64*)) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 ()* @init_mparams to i64*)) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %4 = load i64, i64* %3, align 8, !tbaa !1
  %cmp = icmp eq i64 %4, 0
  br i1 %cmp, label %lor.rhs, label %lor.end

lor.rhs:                                          ; preds = %entry
  %5 = bitcast i64* %2 to i32 ()*
  %call = tail call i32 %5() #7
  br label %lor.end

lor.end:                                          ; preds = %entry, %lor.rhs
  ret i8* null
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #2

; Function Attrs: nounwind uwtable
define internal i32 @init_mparams() #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %1 = bitcast i64* %0 to void ()*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i64 (i32)* @sysconf to i64*)) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %magic = alloca i64, align 8
  %4 = load i64, i64* %3, align 8, !tbaa !1
  %cmp = icmp eq i64 %4, 0
  br i1 %cmp, label %if.then, label %if.end7

if.then:                                          ; preds = %entry
  %5 = bitcast i64* %2 to i64 (i32)*
  %6 = bitcast i64* %magic to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %6) #7
  %call = tail call i64 %5(i32 30) #7
  %sub2 = add i64 %call, -1
  %and3 = and i64 %sub2, %call
  %cmp4 = icmp eq i64 %and3, 0
  br i1 %cmp4, label %if.end, label %if.then5

if.then5:                                         ; preds = %if.then
  tail call void %1() #8
  unreachable

if.end:                                           ; preds = %if.then
  %7 = getelementptr i64, i64* %3, i64 2
  %8 = getelementptr i64, i64* %3, i64 1
  store i64 %call, i64* %8, align 8, !tbaa !7
  %9 = bitcast i64* %7 to <2 x i64>*
  store <2 x i64> <i64 65536, i64 -1>, <2 x i64>* %9, align 8, !tbaa !8
  %10 = getelementptr i64, i64* %3, i64 4
  store i64 2097152, i64* %10, align 8, !tbaa !9
  %11 = getelementptr i64, i64* %3, i64 5
  %12 = bitcast i64* %11 to i32*
  store i32 4, i32* %12, align 8, !tbaa !10
  %13 = tail call i64* asm "mov $1,$0;sub %rsp,$0;add %r13,$0;", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* nonnull %magic) #7
  %14 = ptrtoint i64* %13 to i64
  %xor = and i64 %14, -16
  %and6 = xor i64 %xor, 1431655768
  store volatile i64 %and6, i64* %3, align 8, !tbaa !8
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %6) #7
  br label %if.end7

if.end7:                                          ; preds = %if.end, %entry
  ret i32 1
}

; Function Attrs: nounwind uwtable
define internal %struct.malloc_state* @init_user_mstate(i8* %tbase, i64 %tsize) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*, %struct.malloc_chunk*, i64)* @init_top to i64*)) #7
  %1 = bitcast i64* %0 to void (%struct.malloc_state*, %struct.malloc_chunk*, i64)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*)* @init_bins to i64*)) #7
  %3 = bitcast i64* %2 to void (%struct.malloc_state*)*
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %5 = bitcast i8* %tbase to i64*
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %5) #7
  %7 = bitcast i64* %6 to i8*
  %add.ptr = getelementptr inbounds i8, i8* %tbase, i64 16
  %8 = ptrtoint i8* %add.ptr to i64
  %and = and i64 %8, 15
  %cmp = icmp eq i64 %and, 0
  %sub = sub i64 0, %8
  %and3 = and i64 %sub, 15
  %cond = select i1 %cmp, i64 0, i64 %and3
  %add.ptr4 = getelementptr inbounds i8, i8* %tbase, i64 %cond
  %9 = getelementptr inbounds i8, i8* %7, i64 %cond
  %add.ptr5 = getelementptr inbounds i8, i8* %add.ptr4, i64 16
  %10 = getelementptr inbounds i8, i8* %9, i64 16
  %11 = bitcast i8* %add.ptr5 to %struct.malloc_state*
  tail call void @llvm.memset.p0i8.i64(i8* %10, i8 0, i64 944, i32 8, i1 false)
  %12 = getelementptr inbounds i8, i8* %9, i64 8
  %13 = bitcast i8* %12 to i64*
  store i64 947, i64* %13, align 8, !tbaa !11
  %14 = getelementptr inbounds i8, i8* %10, i64 24
  %15 = bitcast i8* %14 to i8**
  store i8* %tbase, i8** %15, align 8, !tbaa !14
  %16 = getelementptr inbounds i8, i8* %10, i64 888
  %17 = bitcast i8* %16 to i8**
  store i8* %tbase, i8** %17, align 8, !tbaa !17
  %18 = getelementptr inbounds i8, i8* %10, i64 864
  %19 = bitcast i8* %18 to i64*
  store i64 %tsize, i64* %19, align 8, !tbaa !18
  %20 = getelementptr inbounds i8, i8* %10, i64 856
  %21 = bitcast i8* %20 to i64*
  store i64 %tsize, i64* %21, align 8, !tbaa !19
  %22 = getelementptr inbounds i8, i8* %16, i64 8
  %23 = bitcast i8* %22 to i64*
  store i64 %tsize, i64* %23, align 8, !tbaa !20
  %24 = load i64, i64* %4, align 8, !tbaa !1
  %25 = getelementptr inbounds i8, i8* %10, i64 64
  %26 = bitcast i8* %25 to i64*
  store i64 %24, i64* %26, align 8, !tbaa !21
  %27 = getelementptr inbounds i8, i8* %10, i64 56
  %28 = bitcast i8* %27 to i64*
  store i64 -1, i64* %28, align 8, !tbaa !22
  %29 = getelementptr i64, i64* %4, i64 5
  %30 = bitcast i64* %29 to i32*
  %31 = load i32, i32* %30, align 8, !tbaa !23
  %32 = getelementptr inbounds i8, i8* %10, i64 880
  %33 = bitcast i8* %32 to i32*
  %34 = getelementptr inbounds i8, i8* %10, i64 920
  %or8 = or i32 %31, 4
  call void @llvm.memset.p0i8.i64(i8* %34, i8 0, i64 16, i32 8, i1 false)
  store i32 %or8, i32* %33, align 8, !tbaa !24
  tail call void %3(%struct.malloc_state* %11) #7
  %add.ptr9 = getelementptr inbounds i8, i8* %add.ptr5, i64 -16
  %35 = getelementptr inbounds i8, i8* %10, i64 -16
  %36 = getelementptr inbounds i8, i8* %35, i64 8
  %37 = bitcast i8* %36 to i64*
  %38 = load i64, i64* %37, align 8, !tbaa !11
  %and12 = and i64 %38, -8
  %add.ptr13 = getelementptr inbounds i8, i8* %add.ptr9, i64 %and12
  %39 = bitcast i8* %add.ptr13 to %struct.malloc_chunk*
  %add.ptr14 = getelementptr inbounds i8, i8* %tbase, i64 %tsize
  %sub.ptr.lhs.cast = ptrtoint i8* %add.ptr14 to i64
  %sub.ptr.rhs.cast = ptrtoint i8* %add.ptr13 to i64
  %sub.ptr.sub = add i64 %sub.ptr.lhs.cast, -80
  %sub15 = sub i64 %sub.ptr.sub, %sub.ptr.rhs.cast
  tail call void %1(%struct.malloc_state* %11, %struct.malloc_chunk* %39, i64 %sub15) #7
  ret %struct.malloc_state* %11
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #2

; Function Attrs: nounwind uwtable
define i8* @create_mspace_with_base(i8* %base, i64 %capacity, i32 %locked) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (%struct.malloc_state* (i8*, i64)* @init_user_mstate to i64*)) #7
  %1 = bitcast i64* %0 to %struct.malloc_state* (i8*, i64)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 ()* @init_mparams to i64*)) #7
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %5 = load i64, i64* %4, align 8, !tbaa !1
  %cmp = icmp eq i64 %5, 0
  br i1 %cmp, label %lor.rhs, label %lor.end

lor.rhs:                                          ; preds = %entry
  %6 = bitcast i64* %3 to i32 ()*
  %call = tail call i32 %6() #7
  br label %lor.end

lor.end:                                          ; preds = %entry, %lor.rhs
  %cmp1 = icmp ugt i64 %capacity, 1024
  br i1 %cmp1, label %land.lhs.true, label %if.end

land.lhs.true:                                    ; preds = %lor.end
  %7 = getelementptr i64, i64* %4, i64 1
  %8 = load i64, i64* %7, align 8, !tbaa !7
  %sub = sub i64 -1024, %8
  %cmp4 = icmp ugt i64 %sub, %capacity
  br i1 %cmp4, label %if.then, label %if.end

if.then:                                          ; preds = %land.lhs.true
  %call5 = tail call %struct.malloc_state* %1(i8* %base, i64 %capacity) #7
  %9 = bitcast %struct.malloc_state* %call5 to i64*
  %10 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %9) #7
  %11 = getelementptr inbounds i64, i64* %10, i64 114
  %12 = bitcast i64* %11 to i32*
  store i32 8, i32* %12, align 8, !tbaa !25
  %phitmp = bitcast %struct.malloc_state* %call5 to i8*
  br label %if.end

if.end:                                           ; preds = %if.then, %land.lhs.true, %lor.end
  %m.0 = phi i8* [ %phitmp, %if.then ], [ null, %land.lhs.true ], [ null, %lor.end ]
  ret i8* %m.0
}

; Function Attrs: nounwind uwtable
define i32 @mspace_track_large_chunks(i8* %msp, i32 %enable) local_unnamed_addr #0 {
entry:
  %0 = bitcast i8* %msp to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  ret i32 1
}

; Function Attrs: nounwind uwtable
define i64 @destroy_mspace(i8* %msp) local_unnamed_addr #0 {
while.body.preheader:
  %0 = bitcast i8* %msp to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  %2 = getelementptr inbounds i64, i64* %1, i64 111
  %3 = bitcast i64* %2 to %struct.malloc_segment*
  br label %while.body

while.body:                                       ; preds = %while.body.preheader, %while.body
  %4 = phi %struct.malloc_segment* [ %6, %while.body ], [ %3, %while.body.preheader ]
  %5 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %4, i64 0, i32 2
  %6 = load %struct.malloc_segment*, %struct.malloc_segment** %5, align 8, !tbaa !26
  %7 = bitcast %struct.malloc_segment* %6 to i64*
  %8 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %7) #7
  %cmp = icmp eq %struct.malloc_segment* %6, null
  br i1 %cmp, label %while.end, label %while.body

while.end:                                        ; preds = %while.body
  ret i64 0
}

; Function Attrs: nounwind uwtable
define i8* @mspace_malloc(i8* %msp, i64 %bytes) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (%struct.malloc_state*, i64)* @sys_alloc to i64*)) #7
  %1 = bitcast i64* %0 to i8* (%struct.malloc_state*, i64)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (%struct.malloc_state*, i64)* @tmalloc_small to i64*)) #7
  %3 = bitcast i64* %2 to i8* (%struct.malloc_state*, i64)*
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %5 = bitcast i64* %4 to void ()*
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (%struct.malloc_state*, i64)* @tmalloc_large to i64*)) #7
  %7 = bitcast i64* %6 to i8* (%struct.malloc_state*, i64)*
  %8 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* undef) #7
  %9 = bitcast i8* %msp to i64*
  %10 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %9) #7
  %11 = bitcast i8* %msp to %struct.malloc_state*
  %12 = bitcast i64* %10 to %struct.malloc_state*
  %cmp = icmp ult i64 %bytes, 233
  br i1 %cmp, label %if.then, label %if.else162

if.then:                                          ; preds = %entry
  %cmp1 = icmp ult i64 %bytes, 23
  %add2 = add i64 %bytes, 23
  %and = and i64 %add2, -16
  %cond = select i1 %cmp1, i64 32, i64 %and
  %shr = lshr exact i64 %cond, 3
  %conv = trunc i64 %shr to i32
  %13 = bitcast i64* %10 to i32*
  %14 = load i32, i32* %13, align 8, !tbaa !27
  %shr3 = lshr i32 %14, %conv
  %and4 = and i32 %shr3, 3
  %cmp5 = icmp eq i32 %and4, 0
  br i1 %cmp5, label %if.else35, label %if.then7

if.then7:                                         ; preds = %if.then
  %neg = and i32 %shr3, 1
  %and8 = or i32 %neg, %conv
  %add9 = xor i32 %and8, 1
  %smallbins = getelementptr inbounds i8, i8* %msp, i64 72
  %15 = bitcast i8* %smallbins to [66 x %struct.malloc_chunk*]*
  %16 = getelementptr inbounds i64, i64* %10, i64 9
  %17 = bitcast i64* %16 to [66 x %struct.malloc_chunk*]*
  %shl = shl i32 %add9, 1
  %idxprom = zext i32 %shl to i64
  %arrayidx = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %15, i64 0, i64 %idxprom
  %18 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %17, i64 0, i64 %idxprom
  %19 = bitcast %struct.malloc_chunk** %arrayidx to %struct.malloc_chunk*
  %20 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %18, i64 2
  %21 = load %struct.malloc_chunk*, %struct.malloc_chunk** %20, align 8, !tbaa !28
  %22 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %21, i64 0, i32 0
  %23 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %22) #7
  %24 = getelementptr inbounds i64, i64* %23, i64 2
  %25 = bitcast i64* %24 to %struct.malloc_chunk**
  %26 = load %struct.malloc_chunk*, %struct.malloc_chunk** %25, align 8, !tbaa !28
  %cmp11 = icmp eq %struct.malloc_chunk* %26, %19
  %27 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %26, i64 0, i32 0
  %28 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %27) #7
  br i1 %cmp11, label %if.then13, label %if.else

if.then13:                                        ; preds = %if.then7
  %shl14 = shl i32 1, %add9
  %neg15 = xor i32 %shl14, -1
  %and17 = and i32 %14, %neg15
  store i32 %and17, i32* %13, align 8, !tbaa !27
  br label %if.end27

if.else:                                          ; preds = %if.then7
  %29 = bitcast %struct.malloc_chunk* %26 to i8*
  %30 = getelementptr inbounds i64, i64* %10, i64 3
  %31 = bitcast i64* %30 to i8**
  %32 = load i8*, i8** %31, align 8, !tbaa !14
  %cmp18 = icmp ugt i8* %32, %29
  br i1 %cmp18, label %if.else26, label %land.rhs

land.rhs:                                         ; preds = %if.else
  %33 = getelementptr inbounds i64, i64* %28, i64 3
  %34 = bitcast i64* %33 to %struct.malloc_chunk**
  %35 = load %struct.malloc_chunk*, %struct.malloc_chunk** %34, align 8, !tbaa !29
  %cmp20 = icmp eq %struct.malloc_chunk* %35, %21
  br i1 %cmp20, label %if.then23, label %if.else26, !prof !30

if.then23:                                        ; preds = %land.rhs
  %36 = bitcast i64* %33 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx, %struct.malloc_chunk*** %36, align 8, !tbaa !29
  store %struct.malloc_chunk* %26, %struct.malloc_chunk** %20, align 8, !tbaa !28
  br label %if.end27

if.else26:                                        ; preds = %if.else, %land.rhs
  tail call void %5() #8
  unreachable

if.end27:                                         ; preds = %if.then23, %if.then13
  %shl28 = shl i32 %add9, 3
  %conv29 = zext i32 %shl28 to i64
  %or30 = or i64 %conv29, 3
  %37 = getelementptr inbounds i64, i64* %23, i64 1
  store i64 %or30, i64* %37, align 8, !tbaa !11
  %38 = bitcast i64* %23 to i8*
  %39 = getelementptr inbounds i8, i8* %38, i64 %conv29
  %40 = getelementptr inbounds i8, i8* %39, i64 8
  %41 = bitcast i8* %40 to i64*
  %42 = load i64, i64* %41, align 8, !tbaa !11
  %or33 = or i64 %42, 1
  store i64 %or33, i64* %41, align 8, !tbaa !11
  %add.ptr34 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %21, i64 0, i32 2
  %43 = bitcast %struct.malloc_chunk** %add.ptr34 to i8*
  br label %cleanup243

if.else35:                                        ; preds = %if.then
  %44 = getelementptr inbounds i64, i64* %10, i64 1
  %45 = load i64, i64* %44, align 8, !tbaa !31
  %cmp36 = icmp ugt i64 %cond, %45
  br i1 %cmp36, label %if.then38, label %if.end180

if.then38:                                        ; preds = %if.else35
  %cmp39 = icmp eq i32 %shr3, 0
  br i1 %cmp39, label %if.else151, label %if.then41

if.then41:                                        ; preds = %if.then38
  %shl44 = shl i32 %shr3, %conv
  %shl46 = shl i32 2, %conv
  %sub = sub i32 0, %shl46
  %or49 = or i32 %shl46, %sub
  %and50 = and i32 %shl44, %or49
  %sub51 = sub i32 0, %and50
  %and52 = and i32 %and50, %sub51
  %46 = tail call i32 @llvm.cttz.i32(i32 %and52, i1 true)
  %smallbins53 = getelementptr inbounds i8, i8* %msp, i64 72
  %47 = bitcast i8* %smallbins53 to [66 x %struct.malloc_chunk*]*
  %48 = getelementptr inbounds i64, i64* %10, i64 9
  %49 = bitcast i64* %48 to [66 x %struct.malloc_chunk*]*
  %shl54 = shl nuw nsw i32 %46, 1
  %idxprom55 = zext i32 %shl54 to i64
  %arrayidx56 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %47, i64 0, i64 %idxprom55
  %50 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %49, i64 0, i64 %idxprom55
  %51 = bitcast %struct.malloc_chunk** %arrayidx56 to %struct.malloc_chunk*
  %52 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %50, i64 2
  %53 = load %struct.malloc_chunk*, %struct.malloc_chunk** %52, align 8, !tbaa !28
  %54 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %53, i64 0, i32 0
  %55 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %54) #7
  %56 = getelementptr inbounds i64, i64* %55, i64 2
  %57 = bitcast i64* %56 to %struct.malloc_chunk**
  %58 = load %struct.malloc_chunk*, %struct.malloc_chunk** %57, align 8, !tbaa !28
  %cmp60 = icmp eq %struct.malloc_chunk* %58, %51
  %59 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %58, i64 0, i32 0
  %60 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %59) #7
  br i1 %cmp60, label %if.then62, label %if.else67

if.then62:                                        ; preds = %if.then41
  %shl63 = shl i32 1, %46
  %neg64 = xor i32 %shl63, -1
  %and66 = and i32 %14, %neg64
  store i32 %and66, i32* %13, align 8, !tbaa !27
  br label %if.end85

if.else67:                                        ; preds = %if.then41
  %61 = bitcast %struct.malloc_chunk* %58 to i8*
  %62 = getelementptr inbounds i64, i64* %10, i64 3
  %63 = bitcast i64* %62 to i8**
  %64 = load i8*, i8** %63, align 8, !tbaa !14
  %cmp69 = icmp ugt i8* %64, %61
  br i1 %cmp69, label %if.else83, label %land.rhs71

land.rhs71:                                       ; preds = %if.else67
  %65 = getelementptr inbounds i64, i64* %60, i64 3
  %66 = bitcast i64* %65 to %struct.malloc_chunk**
  %67 = load %struct.malloc_chunk*, %struct.malloc_chunk** %66, align 8, !tbaa !29
  %cmp73 = icmp eq %struct.malloc_chunk* %67, %53
  br i1 %cmp73, label %if.then80, label %if.else83, !prof !30

if.then80:                                        ; preds = %land.rhs71
  %68 = bitcast i64* %65 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx56, %struct.malloc_chunk*** %68, align 8, !tbaa !29
  store %struct.malloc_chunk* %58, %struct.malloc_chunk** %52, align 8, !tbaa !28
  br label %if.end85

if.else83:                                        ; preds = %if.else67, %land.rhs71
  tail call void %5() #8
  unreachable

if.end85:                                         ; preds = %if.then80, %if.then62
  %shl86 = shl nuw nsw i32 %46, 3
  %conv87 = zext i32 %shl86 to i64
  %sub88 = sub i64 %conv87, %cond
  %cmp89 = icmp ult i64 %sub88, 32
  br i1 %cmp89, label %if.then91, label %if.else102

if.then91:                                        ; preds = %if.end85
  %or95 = or i64 %conv87, 3
  %69 = getelementptr inbounds i64, i64* %55, i64 1
  store i64 %or95, i64* %69, align 8, !tbaa !11
  %70 = bitcast i64* %55 to i8*
  %71 = getelementptr inbounds i8, i8* %70, i64 %conv87
  %72 = getelementptr inbounds i8, i8* %71, i64 8
  %73 = bitcast i8* %72 to i64*
  %74 = load i64, i64* %73, align 8, !tbaa !11
  %or101 = or i64 %74, 1
  store i64 %or101, i64* %73, align 8, !tbaa !11
  br label %if.end149

if.else102:                                       ; preds = %if.end85
  %or104 = or i64 %cond, 3
  %75 = getelementptr inbounds i64, i64* %55, i64 1
  store i64 %or104, i64* %75, align 8, !tbaa !11
  %76 = bitcast %struct.malloc_chunk* %53 to i8*
  %77 = bitcast i64* %55 to i8*
  %add.ptr106 = getelementptr inbounds i8, i8* %76, i64 %cond
  %78 = getelementptr inbounds i8, i8* %77, i64 %cond
  %or107 = or i64 %sub88, 1
  %79 = getelementptr inbounds i8, i8* %78, i64 8
  %80 = bitcast i8* %79 to i64*
  store i64 %or107, i64* %80, align 8, !tbaa !11
  %81 = getelementptr inbounds i8, i8* %77, i64 %conv87
  %82 = bitcast i8* %81 to i64*
  store i64 %sub88, i64* %82, align 8, !tbaa !32
  %83 = load i64, i64* %44, align 8, !tbaa !31
  %cmp111 = icmp eq i64 %83, 0
  %.pre405 = getelementptr inbounds i64, i64* %10, i64 4
  br i1 %cmp111, label %if.end146, label %if.then113

if.then113:                                       ; preds = %if.else102
  %84 = bitcast i64* %.pre405 to %struct.malloc_chunk**
  %85 = load %struct.malloc_chunk*, %struct.malloc_chunk** %84, align 8, !tbaa !33
  %shr114 = lshr i64 %83, 3
  %conv115 = trunc i64 %shr114 to i32
  %shl117400 = shl nuw nsw i64 %shr114, 1
  %idxprom118 = and i64 %shl117400, 4294967294
  %arrayidx119 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %47, i64 0, i64 %idxprom118
  %86 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %49, i64 0, i64 %idxprom118
  %87 = load i32, i32* %13, align 8, !tbaa !27
  %shl122 = shl i32 1, %conv115
  %and123 = and i32 %87, %shl122
  %tobool124 = icmp eq i32 %and123, 0
  %88 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %85, i64 0, i32 0
  %89 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %88) #7
  br i1 %tobool124, label %if.then125, label %if.else129

if.then125:                                       ; preds = %if.then113
  %90 = bitcast %struct.malloc_chunk** %86 to %struct.malloc_chunk*
  %91 = bitcast %struct.malloc_chunk** %arrayidx119 to %struct.malloc_chunk*
  %or128 = or i32 %87, %shl122
  store i32 %or128, i32* %13, align 8, !tbaa !27
  %.pre = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %86, i64 2
  br label %if.end141

if.else129:                                       ; preds = %if.then113
  %92 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %86, i64 2
  %93 = load %struct.malloc_chunk*, %struct.malloc_chunk** %92, align 8, !tbaa !28
  %94 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %93, i64 0, i32 0
  %95 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %94) #7
  %96 = bitcast %struct.malloc_chunk* %93 to i8*
  %97 = getelementptr inbounds i64, i64* %10, i64 3
  %98 = bitcast i64* %97 to i8**
  %99 = load i8*, i8** %98, align 8, !tbaa !14
  %cmp132 = icmp ugt i8* %99, %96
  br i1 %cmp132, label %if.else139, label %if.end141, !prof !34

if.else139:                                       ; preds = %if.else129
  tail call void %5() #8
  unreachable

if.end141:                                        ; preds = %if.else129, %if.then125
  %.pre-phi = phi %struct.malloc_chunk** [ %92, %if.else129 ], [ %.pre, %if.then125 ]
  %F120.0 = phi %struct.malloc_chunk* [ %93, %if.else129 ], [ %91, %if.then125 ]
  %100 = phi %struct.malloc_chunk* [ %93, %if.else129 ], [ %90, %if.then125 ]
  store %struct.malloc_chunk* %85, %struct.malloc_chunk** %.pre-phi, align 8, !tbaa !28
  %101 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %100, i64 0, i32 3
  store %struct.malloc_chunk* %85, %struct.malloc_chunk** %101, align 8, !tbaa !29
  %102 = getelementptr inbounds i64, i64* %89, i64 2
  %103 = bitcast i64* %102 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %F120.0, %struct.malloc_chunk** %103, align 8, !tbaa !28
  %104 = getelementptr inbounds i64, i64* %89, i64 3
  %105 = bitcast i64* %104 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx119, %struct.malloc_chunk*** %105, align 8, !tbaa !29
  br label %if.end146

if.end146:                                        ; preds = %if.else102, %if.end141
  store i64 %sub88, i64* %44, align 8, !tbaa !31
  %106 = bitcast i64* %.pre405 to i8**
  store i8* %add.ptr106, i8** %106, align 8, !tbaa !33
  br label %if.end149

if.end149:                                        ; preds = %if.end146, %if.then91
  %add.ptr150 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %53, i64 0, i32 2
  %107 = bitcast %struct.malloc_chunk** %add.ptr150 to i8*
  br label %cleanup243

if.else151:                                       ; preds = %if.then38
  %108 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %12, i64 0, i32 1
  %109 = load i32, i32* %108, align 4, !tbaa !35
  %cmp152 = icmp eq i32 %109, 0
  br i1 %cmp152, label %if.end180, label %land.lhs.true

land.lhs.true:                                    ; preds = %if.else151
  %call = tail call i8* %3(%struct.malloc_state* %11, i64 %cond) #7
  %cmp154 = icmp eq i8* %call, null
  %110 = bitcast i8* %call to i64*
  %111 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %110) #7
  br i1 %cmp154, label %if.end180, label %cleanup243

if.else162:                                       ; preds = %entry
  %cmp163 = icmp ugt i64 %bytes, -129
  br i1 %cmp163, label %if.end180, label %if.else166

if.else166:                                       ; preds = %if.else162
  %add168 = add i64 %bytes, 23
  %and169 = and i64 %add168, -16
  %112 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %12, i64 0, i32 1
  %113 = load i32, i32* %112, align 4, !tbaa !35
  %cmp171 = icmp eq i32 %113, 0
  br i1 %cmp171, label %if.end180, label %land.lhs.true173

land.lhs.true173:                                 ; preds = %if.else166
  %call174 = tail call i8* %7(%struct.malloc_state* %11, i64 %and169) #7
  %cmp175 = icmp eq i8* %call174, null
  %114 = bitcast i8* %call174 to i64*
  %115 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %114) #7
  br i1 %cmp175, label %if.end180, label %cleanup243

if.end180:                                        ; preds = %land.lhs.true, %if.else151, %if.else35, %if.else162, %land.lhs.true173, %if.else166
  %nb.0 = phi i64 [ %and169, %land.lhs.true173 ], [ %and169, %if.else166 ], [ -1, %if.else162 ], [ %cond, %if.else35 ], [ %cond, %if.else151 ], [ %cond, %land.lhs.true ]
  %116 = getelementptr inbounds i64, i64* %10, i64 1
  %117 = load i64, i64* %116, align 8, !tbaa !31
  %cmp182 = icmp ult i64 %117, %nb.0
  br i1 %cmp182, label %if.else218, label %if.then184

if.then184:                                       ; preds = %if.end180
  %sub187 = sub i64 %117, %nb.0
  %118 = getelementptr inbounds i64, i64* %10, i64 4
  %119 = bitcast i64* %118 to %struct.malloc_chunk**
  %120 = load %struct.malloc_chunk*, %struct.malloc_chunk** %119, align 8, !tbaa !33
  %cmp190 = icmp ugt i64 %sub187, 31
  %121 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %120, i64 0, i32 0
  %122 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %121) #7
  br i1 %cmp190, label %if.then192, label %if.else204

if.then192:                                       ; preds = %if.then184
  %123 = bitcast %struct.malloc_chunk* %120 to i8*
  %124 = bitcast i64* %122 to i8*
  %add.ptr194 = getelementptr inbounds i8, i8* %123, i64 %nb.0
  %125 = getelementptr inbounds i8, i8* %124, i64 %nb.0
  %126 = bitcast i64* %118 to i8**
  store i8* %add.ptr194, i8** %126, align 8, !tbaa !33
  store i64 %sub187, i64* %116, align 8, !tbaa !31
  %or197 = or i64 %sub187, 1
  %127 = getelementptr inbounds i8, i8* %125, i64 8
  %128 = bitcast i8* %127 to i64*
  store i64 %or197, i64* %128, align 8, !tbaa !11
  %129 = getelementptr inbounds i8, i8* %124, i64 %117
  %130 = bitcast i8* %129 to i64*
  store i64 %sub187, i64* %130, align 8, !tbaa !32
  %or202 = or i64 %nb.0, 3
  %131 = getelementptr inbounds i64, i64* %122, i64 1
  store i64 %or202, i64* %131, align 8, !tbaa !11
  br label %if.end214

if.else204:                                       ; preds = %if.then184
  store i64 0, i64* %116, align 8, !tbaa !31
  store %struct.malloc_chunk* null, %struct.malloc_chunk** %119, align 8, !tbaa !33
  %or209 = or i64 %117, 3
  %132 = getelementptr inbounds i64, i64* %122, i64 1
  store i64 %or209, i64* %132, align 8, !tbaa !11
  %133 = bitcast i64* %122 to i8*
  %134 = getelementptr inbounds i8, i8* %133, i64 %117
  %135 = getelementptr inbounds i8, i8* %134, i64 8
  %136 = bitcast i8* %135 to i64*
  %137 = load i64, i64* %136, align 8, !tbaa !11
  %or213 = or i64 %137, 1
  store i64 %or213, i64* %136, align 8, !tbaa !11
  br label %if.end214

if.end214:                                        ; preds = %if.else204, %if.then192
  %add.ptr215 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %120, i64 0, i32 2
  %138 = bitcast %struct.malloc_chunk** %add.ptr215 to i8*
  br label %cleanup243

if.else218:                                       ; preds = %if.end180
  %139 = getelementptr inbounds i64, i64* %10, i64 2
  %140 = load i64, i64* %139, align 8, !tbaa !36
  %cmp219 = icmp ugt i64 %140, %nb.0
  br i1 %cmp219, label %if.then221, label %if.end239

if.then221:                                       ; preds = %if.else218
  %sub224 = sub i64 %140, %nb.0
  store i64 %sub224, i64* %139, align 8, !tbaa !36
  %141 = getelementptr inbounds i64, i64* %10, i64 5
  %142 = bitcast i64* %141 to %struct.malloc_chunk**
  %143 = load %struct.malloc_chunk*, %struct.malloc_chunk** %142, align 8, !tbaa !37
  %144 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 0
  %145 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %144) #7
  %146 = bitcast %struct.malloc_chunk* %143 to i8*
  %147 = bitcast i64* %145 to i8*
  %add.ptr227 = getelementptr inbounds i8, i8* %146, i64 %nb.0
  %148 = getelementptr inbounds i8, i8* %147, i64 %nb.0
  %149 = bitcast i64* %141 to i8**
  store i8* %add.ptr227, i8** %149, align 8, !tbaa !37
  %or229 = or i64 %sub224, 1
  %150 = getelementptr inbounds i8, i8* %148, i64 8
  %151 = bitcast i8* %150 to i64*
  store i64 %or229, i64* %151, align 8, !tbaa !11
  %or232 = or i64 %nb.0, 3
  %152 = getelementptr inbounds i64, i64* %145, i64 1
  store i64 %or232, i64* %152, align 8, !tbaa !11
  %add.ptr234 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 2
  %153 = bitcast %struct.malloc_chunk** %add.ptr234 to i8*
  br label %cleanup243

if.end239:                                        ; preds = %if.else218
  %call240 = tail call i8* %1(%struct.malloc_state* %11, i64 %nb.0) #7
  %154 = bitcast i8* %call240 to i64*
  %155 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %154) #7
  br label %cleanup243

cleanup243:                                       ; preds = %land.lhs.true, %if.end149, %if.end27, %if.end239, %land.lhs.true173, %if.end214, %if.then221
  %retval.0 = phi i8* [ %138, %if.end214 ], [ %153, %if.then221 ], [ %call240, %if.end239 ], [ %call174, %land.lhs.true173 ], [ %call, %land.lhs.true ], [ %107, %if.end149 ], [ %43, %if.end27 ]
  ret i8* %retval.0
}

; Function Attrs: noreturn nounwind
declare void @abort() #3

; Function Attrs: nounwind readnone
declare i32 @llvm.cttz.i32(i32, i1) #4

; Function Attrs: nounwind uwtable
define internal i8* @tmalloc_small(%struct.malloc_state* %m, i64 %nb) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* undef) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %2 = bitcast i64* %1 to void ()*
  %3 = bitcast %struct.malloc_state* %m to i64*
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %3) #7
  %5 = bitcast i64* %4 to %struct.malloc_state*
  %6 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %5, i64 0, i32 1
  %7 = load i32, i32* %6, align 4, !tbaa !35
  %sub = sub i32 0, %7
  %and = and i32 %7, %sub
  %8 = tail call i32 @llvm.cttz.i32(i32 %and, i1 true)
  %9 = getelementptr inbounds i64, i64* %4, i64 75
  %10 = bitcast i64* %9 to [32 x %struct.malloc_tree_chunk*]*
  %idxprom = zext i32 %8 to i64
  %11 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %10, i64 0, i64 %idxprom
  %12 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %11, align 8, !tbaa !38
  %13 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %12, i64 0, i32 0
  %14 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %13) #7
  %15 = bitcast i64* %14 to %struct.malloc_tree_chunk*
  %16 = getelementptr inbounds i64, i64* %14, i64 1
  %17 = load i64, i64* %16, align 8, !tbaa !39
  %and2 = and i64 %17, -8
  %sub3 = sub i64 %and2, %nb
  %18 = getelementptr inbounds i64, i64* %14, i64 4
  %19 = bitcast i64* %18 to %struct.malloc_tree_chunk**
  %20 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %19, align 8, !tbaa !38
  %cmp349 = icmp eq %struct.malloc_tree_chunk* %20, null
  %.sink350 = zext i1 %cmp349 to i64
  %21 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %15, i64 0, i32 4, i64 %.sink350
  %22 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %21, align 8, !tbaa !38
  %cmp9351 = icmp eq %struct.malloc_tree_chunk* %22, null
  %23 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %22, i64 0, i32 0
  %24 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %23) #7
  br i1 %cmp9351, label %while.end, label %while.body

while.body:                                       ; preds = %entry, %while.body
  %25 = phi i64* [ %34, %while.body ], [ %24, %entry ]
  %26 = phi %struct.malloc_tree_chunk* [ %32, %while.body ], [ %22, %entry ]
  %v.0353 = phi %struct.malloc_tree_chunk* [ %.v.0, %while.body ], [ %12, %entry ]
  %rsize.0352 = phi i64 [ %sub12.rsize.0, %while.body ], [ %sub3, %entry ]
  %27 = getelementptr inbounds i64, i64* %25, i64 1
  %28 = load i64, i64* %27, align 8, !tbaa !39
  %and11 = and i64 %28, -8
  %sub12 = sub i64 %and11, %nb
  %cmp13 = icmp ult i64 %sub12, %rsize.0352
  %sub12.rsize.0 = select i1 %cmp13, i64 %sub12, i64 %rsize.0352
  %.v.0 = select i1 %cmp13, %struct.malloc_tree_chunk* %26, %struct.malloc_tree_chunk* %v.0353
  %29 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %26, i64 0, i32 4, i64 0
  %30 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %29, align 8, !tbaa !38
  %cmp = icmp eq %struct.malloc_tree_chunk* %30, null
  %.sink = zext i1 %cmp to i64
  %31 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %26, i64 0, i32 4, i64 %.sink
  %32 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %31, align 8, !tbaa !38
  %cmp9 = icmp eq %struct.malloc_tree_chunk* %32, null
  %33 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %32, i64 0, i32 0
  %34 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %33) #7
  br i1 %cmp9, label %while.end, label %while.body

while.end:                                        ; preds = %while.body, %entry
  %rsize.0.lcssa = phi i64 [ %sub3, %entry ], [ %sub12.rsize.0, %while.body ]
  %v.0.lcssa = phi %struct.malloc_tree_chunk* [ %12, %entry ], [ %.v.0, %while.body ]
  %.lcssa348 = phi %struct.malloc_tree_chunk* [ %15, %entry ], [ %.v.0, %while.body ]
  %35 = bitcast %struct.malloc_tree_chunk* %v.0.lcssa to i8*
  %36 = bitcast %struct.malloc_tree_chunk* %.lcssa348 to i8*
  %37 = getelementptr inbounds i64, i64* %4, i64 3
  %38 = bitcast i64* %37 to i8**
  %39 = load i8*, i8** %38, align 8, !tbaa !14
  %cmp14 = icmp ugt i8* %39, %35
  br i1 %cmp14, label %if.end218, label %if.then16, !prof !34

if.then16:                                        ; preds = %while.end
  %add.ptr = getelementptr inbounds i8, i8* %35, i64 %nb
  %40 = getelementptr inbounds i8, i8* %36, i64 %nb
  %cmp17 = icmp ugt i8* %add.ptr, %35
  br i1 %cmp17, label %if.then22, label %if.end218, !prof !30

if.then22:                                        ; preds = %if.then16
  %41 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 5
  %42 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %41, align 8, !tbaa !41
  %43 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 3
  %44 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %43, align 8, !tbaa !42
  %cmp23 = icmp eq %struct.malloc_tree_chunk* %44, %v.0.lcssa
  %45 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %42, i64 0, i32 0
  %46 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %45) #7
  %47 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %44, i64 0, i32 0
  %48 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %47) #7
  br i1 %cmp23, label %if.else43, label %if.then25

if.then25:                                        ; preds = %if.then22
  %49 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 2
  %50 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %49, align 8, !tbaa !43
  %51 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %50, i64 0, i32 0
  %52 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %51) #7
  %53 = bitcast %struct.malloc_tree_chunk* %50 to i8*
  %cmp28 = icmp ugt i8* %39, %53
  br i1 %cmp28, label %if.else, label %land.lhs.true

land.lhs.true:                                    ; preds = %if.then25
  %54 = getelementptr inbounds i64, i64* %52, i64 3
  %55 = bitcast i64* %54 to %struct.malloc_tree_chunk**
  %56 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %55, align 8, !tbaa !42
  %cmp31 = icmp eq %struct.malloc_tree_chunk* %56, %v.0.lcssa
  br i1 %cmp31, label %land.rhs, label %if.else

land.rhs:                                         ; preds = %land.lhs.true
  %57 = getelementptr inbounds i64, i64* %48, i64 2
  %58 = bitcast i64* %57 to %struct.malloc_tree_chunk**
  %59 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %58, align 8, !tbaa !43
  %cmp34 = icmp eq %struct.malloc_tree_chunk* %59, %v.0.lcssa
  br i1 %cmp34, label %if.then39, label %if.else, !prof !30

if.then39:                                        ; preds = %land.rhs
  store %struct.malloc_tree_chunk* %44, %struct.malloc_tree_chunk** %55, align 8, !tbaa !42
  store %struct.malloc_tree_chunk* %50, %struct.malloc_tree_chunk** %58, align 8, !tbaa !43
  br label %if.end74

if.else:                                          ; preds = %if.then25, %land.lhs.true, %land.rhs
  tail call void %2() #8
  unreachable

if.else43:                                        ; preds = %if.then22
  %arrayidx45 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %v.0.lcssa, i64 0, i32 4, i64 1
  %60 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 4, i64 1
  %61 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %60, align 8, !tbaa !38
  %cmp46 = icmp eq %struct.malloc_tree_chunk* %61, null
  %62 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %61, i64 0, i32 0
  %63 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %62) #7
  %64 = bitcast i64* %63 to %struct.malloc_tree_chunk*
  br i1 %cmp46, label %lor.lhs.false, label %while.cond53

lor.lhs.false:                                    ; preds = %if.else43
  %arrayidx49 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %v.0.lcssa, i64 0, i32 4, i64 0
  %65 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 4, i64 0
  %66 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %65, align 8, !tbaa !38
  %cmp50 = icmp eq %struct.malloc_tree_chunk* %66, null
  %67 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %66, i64 0, i32 0
  %68 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %67) #7
  %69 = bitcast i64* %68 to %struct.malloc_tree_chunk*
  br i1 %cmp50, label %if.end74, label %while.cond53

while.cond53:                                     ; preds = %if.else43, %lor.lhs.false, %while.body62
  %RP.1 = phi %struct.malloc_tree_chunk** [ %CP.0, %while.body62 ], [ %arrayidx49, %lor.lhs.false ], [ %arrayidx45, %if.else43 ]
  %70 = phi %struct.malloc_tree_chunk** [ %CP.0, %while.body62 ], [ %65, %lor.lhs.false ], [ %60, %if.else43 ]
  %R.1 = phi %struct.malloc_tree_chunk* [ %76, %while.body62 ], [ %66, %lor.lhs.false ], [ %61, %if.else43 ]
  %71 = phi %struct.malloc_tree_chunk* [ %76, %while.body62 ], [ %69, %lor.lhs.false ], [ %64, %if.else43 ]
  %arrayidx55 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 1
  %72 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %71, i64 0, i32 4, i64 1
  %73 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %72, align 8, !tbaa !38
  %cmp56 = icmp eq %struct.malloc_tree_chunk* %73, null
  br i1 %cmp56, label %lor.rhs, label %while.body62

lor.rhs:                                          ; preds = %while.cond53
  %arrayidx59 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 0
  %74 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %71, i64 0, i32 4, i64 0
  %75 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %74, align 8, !tbaa !38
  %cmp60 = icmp eq %struct.malloc_tree_chunk* %75, null
  br i1 %cmp60, label %while.end63, label %while.body62

while.body62:                                     ; preds = %lor.rhs, %while.cond53
  %76 = phi %struct.malloc_tree_chunk* [ %73, %while.cond53 ], [ %75, %lor.rhs ]
  %CP.0 = phi %struct.malloc_tree_chunk** [ %arrayidx55, %while.cond53 ], [ %arrayidx59, %lor.rhs ]
  %77 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %76, i64 0, i32 0
  %78 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %77) #7
  br label %while.cond53

while.end63:                                      ; preds = %lor.rhs
  %79 = bitcast %struct.malloc_tree_chunk** %RP.1 to i8*
  %80 = load i8*, i8** %38, align 8, !tbaa !14
  %cmp65 = icmp ugt i8* %80, %79
  br i1 %cmp65, label %if.else71, label %if.then70, !prof !34

if.then70:                                        ; preds = %while.end63
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %70, align 8, !tbaa !38
  br label %if.end74

if.else71:                                        ; preds = %while.end63
  tail call void %2() #8
  unreachable

if.end74:                                         ; preds = %if.then70, %lor.lhs.false, %if.then39
  %R.3 = phi %struct.malloc_tree_chunk* [ %44, %if.then39 ], [ null, %lor.lhs.false ], [ %R.1, %if.then70 ]
  %81 = phi %struct.malloc_tree_chunk* [ %44, %if.then39 ], [ %69, %lor.lhs.false ], [ %R.1, %if.then70 ]
  %cmp75 = icmp eq %struct.malloc_tree_chunk* %42, null
  br i1 %cmp75, label %if.end163, label %if.then77

if.then77:                                        ; preds = %if.end74
  %82 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 6
  %83 = load i32, i32* %82, align 8, !tbaa !44
  %idxprom79 = zext i32 %83 to i64
  %84 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %10, i64 0, i64 %idxprom79
  %85 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %84, align 8, !tbaa !38
  %cmp81 = icmp eq %struct.malloc_tree_chunk* %v.0.lcssa, %85
  br i1 %cmp81, label %if.then83, label %if.else91

if.then83:                                        ; preds = %if.then77
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %84, align 8, !tbaa !38
  %cond = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cond, label %if.end112.thread, label %if.then115

if.end112.thread:                                 ; preds = %if.then83
  %shl = shl i32 1, %83
  %neg = xor i32 %shl, -1
  %86 = load i32, i32* %6, align 4, !tbaa !35
  %and89 = and i32 %86, %neg
  store i32 %and89, i32* %6, align 4, !tbaa !35
  br label %if.end163

if.else91:                                        ; preds = %if.then77
  %87 = bitcast %struct.malloc_tree_chunk* %42 to i8*
  %88 = load i8*, i8** %38, align 8, !tbaa !14
  %cmp93 = icmp ugt i8* %88, %87
  br i1 %cmp93, label %if.else110, label %if.end112, !prof !34

if.else110:                                       ; preds = %if.else91
  tail call void %2() #8
  unreachable

if.end112:                                        ; preds = %if.else91
  %89 = getelementptr inbounds i64, i64* %46, i64 4
  %90 = bitcast i64* %89 to [2 x %struct.malloc_tree_chunk*]*
  %91 = bitcast i64* %89 to %struct.malloc_tree_chunk**
  %92 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %91, align 8, !tbaa !38
  %cmp101 = icmp ne %struct.malloc_tree_chunk* %92, %v.0.lcssa
  %.sink225 = zext i1 %cmp101 to i64
  %93 = getelementptr inbounds [2 x %struct.malloc_tree_chunk*], [2 x %struct.malloc_tree_chunk*]* %90, i64 0, i64 %.sink225
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %93, align 8, !tbaa !38
  %cmp113 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cmp113, label %if.end163, label %if.then115

if.then115:                                       ; preds = %if.then83, %if.end112
  %94 = bitcast %struct.malloc_tree_chunk* %R.3 to i8*
  %95 = load i8*, i8** %38, align 8, !tbaa !14
  %cmp117 = icmp ugt i8* %95, %94
  br i1 %cmp117, label %if.else160, label %if.then122, !prof !34

if.then122:                                       ; preds = %if.then115
  %96 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %81, i64 0, i32 5
  store %struct.malloc_tree_chunk* %42, %struct.malloc_tree_chunk** %96, align 8, !tbaa !41
  %97 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 4, i64 0
  %98 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %97, align 8, !tbaa !38
  %cmp126 = icmp eq %struct.malloc_tree_chunk* %98, null
  %99 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %98, i64 0, i32 0
  %100 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %99) #7
  br i1 %cmp126, label %if.end141, label %if.then128

if.then128:                                       ; preds = %if.then122
  %101 = bitcast %struct.malloc_tree_chunk* %98 to i8*
  %102 = load i8*, i8** %38, align 8, !tbaa !14
  %cmp130 = icmp ugt i8* %102, %101
  br i1 %cmp130, label %if.else139, label %if.then135, !prof !34

if.then135:                                       ; preds = %if.then128
  %103 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %81, i64 0, i32 4, i64 0
  store %struct.malloc_tree_chunk* %98, %struct.malloc_tree_chunk** %103, align 8, !tbaa !38
  %104 = getelementptr inbounds i64, i64* %100, i64 6
  %105 = bitcast i64* %104 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %105, align 8, !tbaa !41
  br label %if.end141

if.else139:                                       ; preds = %if.then128
  tail call void %2() #8
  unreachable

if.end141:                                        ; preds = %if.then122, %if.then135
  %106 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 4, i64 1
  %107 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %106, align 8, !tbaa !38
  %cmp144 = icmp eq %struct.malloc_tree_chunk* %107, null
  %108 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %107, i64 0, i32 0
  %109 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %108) #7
  br i1 %cmp144, label %if.end163, label %if.then146

if.then146:                                       ; preds = %if.end141
  %110 = bitcast %struct.malloc_tree_chunk* %107 to i8*
  %111 = load i8*, i8** %38, align 8, !tbaa !14
  %cmp148 = icmp ugt i8* %111, %110
  br i1 %cmp148, label %if.else157, label %if.then153, !prof !34

if.then153:                                       ; preds = %if.then146
  %112 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %81, i64 0, i32 4, i64 1
  store %struct.malloc_tree_chunk* %107, %struct.malloc_tree_chunk** %112, align 8, !tbaa !38
  %113 = getelementptr inbounds i64, i64* %109, i64 6
  %114 = bitcast i64* %113 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %114, align 8, !tbaa !41
  br label %if.end163

if.else157:                                       ; preds = %if.then146
  tail call void %2() #8
  unreachable

if.else160:                                       ; preds = %if.then115
  tail call void %2() #8
  unreachable

if.end163:                                        ; preds = %if.end112.thread, %if.end112, %if.end141, %if.then153, %if.end74
  %cmp164 = icmp ult i64 %rsize.0.lcssa, 32
  br i1 %cmp164, label %if.then166, label %if.else173

if.then166:                                       ; preds = %if.end163
  %add = add i64 %rsize.0.lcssa, %nb
  %or167 = or i64 %add, 3
  %115 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 1
  store i64 %or167, i64* %115, align 8, !tbaa !39
  %116 = getelementptr inbounds i8, i8* %36, i64 %add
  %117 = getelementptr inbounds i8, i8* %116, i64 8
  %118 = bitcast i8* %117 to i64*
  %119 = load i64, i64* %118, align 8, !tbaa !11
  %or172 = or i64 %119, 1
  store i64 %or172, i64* %118, align 8, !tbaa !11
  br label %cleanup219

if.else173:                                       ; preds = %if.end163
  %or175 = or i64 %nb, 3
  %120 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa348, i64 0, i32 1
  store i64 %or175, i64* %120, align 8, !tbaa !39
  %or177 = or i64 %rsize.0.lcssa, 1
  %121 = getelementptr inbounds i8, i8* %40, i64 8
  %122 = bitcast i8* %121 to i64*
  store i64 %or177, i64* %122, align 8, !tbaa !11
  %123 = getelementptr inbounds i8, i8* %40, i64 %rsize.0.lcssa
  %124 = bitcast i8* %123 to i64*
  store i64 %rsize.0.lcssa, i64* %124, align 8, !tbaa !32
  %125 = getelementptr inbounds i64, i64* %4, i64 1
  %126 = load i64, i64* %125, align 8, !tbaa !31
  %cmp180 = icmp eq i64 %126, 0
  %.pre357 = getelementptr inbounds i64, i64* %4, i64 4
  br i1 %cmp180, label %if.end212, label %if.then182

if.then182:                                       ; preds = %if.else173
  %127 = bitcast i64* %.pre357 to %struct.malloc_chunk**
  %128 = load %struct.malloc_chunk*, %struct.malloc_chunk** %127, align 8, !tbaa !33
  %shr = lshr i64 %126, 3
  %conv183 = trunc i64 %shr to i32
  %129 = getelementptr inbounds i64, i64* %4, i64 9
  %130 = bitcast i64* %129 to [66 x %struct.malloc_chunk*]*
  %shl184344 = shl nuw nsw i64 %shr, 1
  %idxprom185 = and i64 %shl184344, 4294967294
  %arrayidx186 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom185
  %131 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %130, i64 0, i64 %idxprom185
  %132 = bitcast i64* %4 to i32*
  %133 = load i32, i32* %132, align 8, !tbaa !27
  %shl188 = shl i32 1, %conv183
  %and189 = and i32 %133, %shl188
  %tobool190 = icmp eq i32 %and189, 0
  %134 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %128, i64 0, i32 0
  %135 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %134) #7
  br i1 %tobool190, label %if.then191, label %if.else195

if.then191:                                       ; preds = %if.then182
  %136 = bitcast %struct.malloc_chunk** %131 to %struct.malloc_chunk*
  %137 = bitcast %struct.malloc_chunk** %arrayidx186 to %struct.malloc_chunk*
  %or194 = or i32 %133, %shl188
  store i32 %or194, i32* %132, align 8, !tbaa !27
  %.pre = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %131, i64 2
  br label %if.end207

if.else195:                                       ; preds = %if.then182
  %138 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %131, i64 2
  %139 = load %struct.malloc_chunk*, %struct.malloc_chunk** %138, align 8, !tbaa !28
  %140 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %139, i64 0, i32 0
  %141 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %140) #7
  %142 = bitcast %struct.malloc_chunk* %139 to i8*
  %143 = load i8*, i8** %38, align 8, !tbaa !14
  %cmp198 = icmp ugt i8* %143, %142
  br i1 %cmp198, label %if.else205, label %if.end207, !prof !34

if.else205:                                       ; preds = %if.else195
  tail call void %2() #8
  unreachable

if.end207:                                        ; preds = %if.else195, %if.then191
  %.pre-phi = phi %struct.malloc_chunk** [ %138, %if.else195 ], [ %.pre, %if.then191 ]
  %F187.0 = phi %struct.malloc_chunk* [ %139, %if.else195 ], [ %137, %if.then191 ]
  %144 = phi %struct.malloc_chunk* [ %139, %if.else195 ], [ %136, %if.then191 ]
  store %struct.malloc_chunk* %128, %struct.malloc_chunk** %.pre-phi, align 8, !tbaa !28
  %145 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %144, i64 0, i32 3
  store %struct.malloc_chunk* %128, %struct.malloc_chunk** %145, align 8, !tbaa !29
  %146 = getelementptr inbounds i64, i64* %135, i64 2
  %147 = bitcast i64* %146 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %F187.0, %struct.malloc_chunk** %147, align 8, !tbaa !28
  %148 = getelementptr inbounds i64, i64* %135, i64 3
  %149 = bitcast i64* %148 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx186, %struct.malloc_chunk*** %149, align 8, !tbaa !29
  br label %if.end212

if.end212:                                        ; preds = %if.else173, %if.end207
  store i64 %rsize.0.lcssa, i64* %125, align 8, !tbaa !31
  %150 = bitcast i64* %.pre357 to i8**
  store i8* %add.ptr, i8** %150, align 8, !tbaa !33
  br label %cleanup219

if.end218:                                        ; preds = %if.then16, %while.end
  tail call void %2() #8
  unreachable

cleanup219:                                       ; preds = %if.end212, %if.then166
  %add.ptr216 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %v.0.lcssa, i64 0, i32 2
  %151 = bitcast %struct.malloc_tree_chunk** %add.ptr216 to i8*
  ret i8* %151
}

; Function Attrs: nounwind uwtable
define internal i8* @tmalloc_large(%struct.malloc_state* %m, i64 %nb) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* undef) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %2 = bitcast i64* %1 to %struct.malloc_tree_chunk*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %4 = bitcast i64* %3 to void ()*
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %6 = bitcast %struct.malloc_state* %m to i64*
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %6) #7
  %8 = bitcast i64* %7 to %struct.malloc_state*
  %sub = sub i64 0, %nb
  %shr = lshr i64 %nb, 8
  %conv = trunc i64 %shr to i32
  %cmp = icmp eq i32 %conv, 0
  br i1 %cmp, label %if.end11, label %if.else

if.else:                                          ; preds = %entry
  %cmp2 = icmp ugt i32 %conv, 65535
  br i1 %cmp2, label %if.end11, label %if.else5

if.else5:                                         ; preds = %if.else
  %9 = tail call i32 @llvm.ctlz.i32(i32 %conv, i1 true)
  %sub6 = xor i32 %9, 31
  %shl = shl nuw nsw i32 %sub6, 1
  %conv7 = zext i32 %shl to i64
  %add = add nuw nsw i32 %sub6, 7
  %sh_prom = zext i32 %add to i64
  %shr8 = lshr i64 %nb, %sh_prom
  %and = and i64 %shr8, 1
  %add9 = or i64 %and, %conv7
  %conv10 = trunc i64 %add9 to i32
  br label %if.end11

if.end11:                                         ; preds = %if.else, %entry, %if.else5
  %idx.0 = phi i32 [ %conv10, %if.else5 ], [ 0, %entry ], [ 31, %if.else ]
  %10 = getelementptr inbounds i64, i64* %7, i64 75
  %11 = bitcast i64* %10 to [32 x %struct.malloc_tree_chunk*]*
  %idxprom = zext i32 %idx.0 to i64
  %12 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %11, i64 0, i64 %idxprom
  %13 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %12, align 8, !tbaa !38
  %cmp12 = icmp eq %struct.malloc_tree_chunk* %13, null
  %14 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %13, i64 0, i32 0
  %15 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %14) #7
  %16 = bitcast i64* %15 to %struct.malloc_tree_chunk*
  br i1 %cmp12, label %if.end50, label %if.then14

if.then14:                                        ; preds = %if.end11
  %cmp15 = icmp eq i32 %idx.0, 31
  br i1 %cmp15, label %cond.end, label %cond.false

cond.false:                                       ; preds = %if.then14
  %shr17 = lshr i32 %idx.0, 1
  %sub19 = add nuw i32 %shr17, 6
  %conv20 = zext i32 %sub19 to i64
  %sub21 = sub nsw i64 63, %conv20
  br label %cond.end

cond.end:                                         ; preds = %if.then14, %cond.false
  %cond = phi i64 [ %sub21, %cond.false ], [ 0, %if.then14 ]
  %shl22 = shl i64 %nb, %cond
  br label %for.cond

for.cond:                                         ; preds = %cleanup, %cond.end
  %rst.0 = phi %struct.malloc_tree_chunk* [ null, %cond.end ], [ %rst.1, %cleanup ]
  %sizebits.0 = phi i64 [ %shl22, %cond.end ], [ %sizebits.0.shl48, %cleanup ]
  %t.0 = phi %struct.malloc_tree_chunk* [ %13, %cond.end ], [ %23, %cleanup ]
  %17 = phi %struct.malloc_tree_chunk* [ %16, %cond.end ], [ %23, %cleanup ]
  %rsize.0 = phi i64 [ %sub, %cond.end ], [ %rsize.1, %cleanup ]
  %v.0 = phi %struct.malloc_tree_chunk* [ null, %cond.end ], [ %v.1, %cleanup ]
  %18 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %17, i64 0, i32 1
  %19 = load i64, i64* %18, align 8, !tbaa !39
  %and23 = and i64 %19, -8
  %sub24 = sub i64 %and23, %nb
  %cmp25 = icmp ult i64 %sub24, %rsize.0
  br i1 %cmp25, label %if.then27, label %cleanup

if.then27:                                        ; preds = %for.cond
  %cmp28 = icmp eq i64 %sub24, 0
  br i1 %cmp28, label %if.end50, label %cleanup

cleanup:                                          ; preds = %for.cond, %if.then27
  %rsize.1 = phi i64 [ %sub24, %if.then27 ], [ %rsize.0, %for.cond ]
  %v.1 = phi %struct.malloc_tree_chunk* [ %t.0, %if.then27 ], [ %v.0, %for.cond ]
  %20 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %17, i64 0, i32 4, i64 1
  %21 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %20, align 8, !tbaa !38
  %shr35 = lshr i64 %sizebits.0, 63
  %22 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %17, i64 0, i32 4, i64 %shr35
  %23 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %22, align 8, !tbaa !38
  %cmp38 = icmp eq %struct.malloc_tree_chunk* %21, null
  %24 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %21, i64 0, i32 0
  %25 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %24) #7
  %26 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %23, i64 0, i32 0
  %27 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %26) #7
  %cmp40 = icmp eq %struct.malloc_tree_chunk* %21, %23
  %or.cond651 = or i1 %cmp38, %cmp40
  %rst.1 = select i1 %or.cond651, %struct.malloc_tree_chunk* %rst.0, %struct.malloc_tree_chunk* %21
  %cmp44 = icmp eq %struct.malloc_tree_chunk* %23, null
  %not.cmp44654 = xor i1 %cmp44, true
  %shl48 = zext i1 %not.cmp44654 to i64
  %sizebits.0.shl48 = shl i64 %sizebits.0, %shl48
  br i1 %cmp44, label %if.end50, label %for.cond

if.end50:                                         ; preds = %cleanup, %if.then27, %if.end11
  %t.2 = phi %struct.malloc_tree_chunk* [ null, %if.end11 ], [ %t.0, %if.then27 ], [ %rst.1, %cleanup ]
  %28 = phi %struct.malloc_tree_chunk* [ %16, %if.end11 ], [ %t.0, %if.then27 ], [ %rst.1, %cleanup ]
  %rsize.3 = phi i64 [ %sub, %if.end11 ], [ 0, %if.then27 ], [ %rsize.1, %cleanup ]
  %v.3 = phi %struct.malloc_tree_chunk* [ null, %if.end11 ], [ %t.0, %if.then27 ], [ %v.1, %cleanup ]
  %29 = phi %struct.malloc_tree_chunk* [ %2, %if.end11 ], [ %t.0, %if.then27 ], [ %v.1, %cleanup ]
  %cmp51 = icmp eq %struct.malloc_tree_chunk* %t.2, null
  %cmp54 = icmp eq %struct.malloc_tree_chunk* %v.3, null
  %or.cond = and i1 %cmp51, %cmp54
  br i1 %or.cond, label %if.then56, label %while.cond.preheader

if.then56:                                        ; preds = %if.end50
  %shl58 = shl i32 2, %idx.0
  %sub61 = sub i32 0, %shl58
  %or = or i32 %shl58, %sub61
  %30 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %8, i64 0, i32 1
  %31 = load i32, i32* %30, align 4, !tbaa !35
  %and62 = and i32 %31, %or
  %cmp63 = icmp eq i32 %and62, 0
  br i1 %cmp63, label %cleanup432, label %if.then65

if.then65:                                        ; preds = %if.then56
  %sub66 = sub i32 0, %and62
  %and67 = and i32 %and62, %sub66
  %32 = tail call i32 @llvm.cttz.i32(i32 %and67, i1 true)
  %idxprom69 = zext i32 %32 to i64
  %33 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %11, i64 0, i64 %idxprom69
  %34 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %33, align 8, !tbaa !38
  %35 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %34, i64 0, i32 0
  %36 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %35) #7
  br label %while.cond.preheader

while.cond.preheader:                             ; preds = %if.then65, %if.end50
  %t.4.ph = phi %struct.malloc_tree_chunk* [ %34, %if.then65 ], [ %t.2, %if.end50 ]
  %.ph656 = phi %struct.malloc_tree_chunk* [ %34, %if.then65 ], [ %28, %if.end50 ]
  %v.4.ph = phi %struct.malloc_tree_chunk* [ null, %if.then65 ], [ %v.3, %if.end50 ]
  %cmp73664 = icmp eq %struct.malloc_tree_chunk* %t.4.ph, null
  br i1 %cmp73664, label %while.end, label %while.body

while.body:                                       ; preds = %while.cond.preheader, %while.body
  %v.4667 = phi %struct.malloc_tree_chunk* [ %t.4.v.4, %while.body ], [ %v.4.ph, %while.cond.preheader ]
  %rsize.4666 = phi i64 [ %sub78.rsize.4, %while.body ], [ %rsize.3, %while.cond.preheader ]
  %37 = phi %struct.malloc_tree_chunk* [ %43, %while.body ], [ %.ph656, %while.cond.preheader ]
  %t.4665 = phi %struct.malloc_tree_chunk* [ %43, %while.body ], [ %t.4.ph, %while.cond.preheader ]
  %38 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %37, i64 0, i32 1
  %39 = load i64, i64* %38, align 8, !tbaa !39
  %and77 = and i64 %39, -8
  %sub78 = sub i64 %and77, %nb
  %cmp79 = icmp ult i64 %sub78, %rsize.4666
  %sub78.rsize.4 = select i1 %cmp79, i64 %sub78, i64 %rsize.4666
  %t.4.v.4 = select i1 %cmp79, %struct.malloc_tree_chunk* %t.4665, %struct.malloc_tree_chunk* %v.4667
  %40 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %37, i64 0, i32 4, i64 0
  %41 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %40, align 8, !tbaa !38
  %cmp85 = icmp eq %struct.malloc_tree_chunk* %41, null
  %.sink = zext i1 %cmp85 to i64
  %42 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %37, i64 0, i32 4, i64 %.sink
  %43 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %42, align 8, !tbaa !38
  %44 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %43, i64 0, i32 0
  %45 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %44) #7
  %cmp73 = icmp eq %struct.malloc_tree_chunk* %43, null
  br i1 %cmp73, label %while.end, label %while.body

while.end:                                        ; preds = %while.body, %while.cond.preheader
  %rsize.4.lcssa = phi i64 [ %rsize.3, %while.cond.preheader ], [ %sub78.rsize.4, %while.body ]
  %v.4.lcssa = phi %struct.malloc_tree_chunk* [ %v.4.ph, %while.cond.preheader ], [ %t.4.v.4, %while.body ]
  %.lcssa663 = phi %struct.malloc_tree_chunk* [ %29, %while.cond.preheader ], [ %t.4.v.4, %while.body ]
  %cmp95 = icmp eq %struct.malloc_tree_chunk* %v.4.lcssa, null
  br i1 %cmp95, label %cleanup432, label %land.lhs.true97

land.lhs.true97:                                  ; preds = %while.end
  %46 = getelementptr inbounds i64, i64* %7, i64 1
  %47 = load i64, i64* %46, align 8, !tbaa !31
  %sub98 = sub i64 %47, %nb
  %cmp99 = icmp ult i64 %rsize.4.lcssa, %sub98
  br i1 %cmp99, label %if.then101, label %cleanup432

if.then101:                                       ; preds = %land.lhs.true97
  %48 = bitcast %struct.malloc_tree_chunk* %v.4.lcssa to i8*
  %49 = bitcast %struct.malloc_tree_chunk* %.lcssa663 to i8*
  %50 = getelementptr inbounds i64, i64* %7, i64 3
  %51 = bitcast i64* %50 to i8**
  %52 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp102 = icmp ugt i8* %52, %48
  br i1 %cmp102, label %if.end430, label %if.then105, !prof !34

if.then105:                                       ; preds = %if.then101
  %add.ptr = getelementptr inbounds i8, i8* %48, i64 %nb
  %53 = getelementptr inbounds i8, i8* %49, i64 %nb
  %cmp106 = icmp ugt i8* %add.ptr, %48
  br i1 %cmp106, label %if.then111, label %if.end430, !prof !30

if.then111:                                       ; preds = %if.then105
  %54 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 5
  %55 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %54, align 8, !tbaa !41
  %56 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 3
  %57 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %56, align 8, !tbaa !42
  %cmp112 = icmp eq %struct.malloc_tree_chunk* %57, %v.4.lcssa
  %58 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %55, i64 0, i32 0
  %59 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %58) #7
  %60 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %57, i64 0, i32 0
  %61 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %60) #7
  br i1 %cmp112, label %if.else134, label %if.then114

if.then114:                                       ; preds = %if.then111
  %62 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 2
  %63 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %62, align 8, !tbaa !43
  %64 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %63, i64 0, i32 0
  %65 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %64) #7
  %66 = bitcast %struct.malloc_tree_chunk* %63 to i8*
  %cmp117 = icmp ugt i8* %52, %66
  br i1 %cmp117, label %if.else132, label %land.lhs.true119

land.lhs.true119:                                 ; preds = %if.then114
  %67 = getelementptr inbounds i64, i64* %65, i64 3
  %68 = bitcast i64* %67 to %struct.malloc_tree_chunk**
  %69 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %68, align 8, !tbaa !42
  %cmp121 = icmp eq %struct.malloc_tree_chunk* %69, %v.4.lcssa
  br i1 %cmp121, label %land.rhs, label %if.else132

land.rhs:                                         ; preds = %land.lhs.true119
  %70 = getelementptr inbounds i64, i64* %61, i64 2
  %71 = bitcast i64* %70 to %struct.malloc_tree_chunk**
  %72 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %71, align 8, !tbaa !43
  %cmp124 = icmp eq %struct.malloc_tree_chunk* %72, %v.4.lcssa
  br i1 %cmp124, label %if.then129, label %if.else132, !prof !30

if.then129:                                       ; preds = %land.rhs
  store %struct.malloc_tree_chunk* %57, %struct.malloc_tree_chunk** %68, align 8, !tbaa !42
  store %struct.malloc_tree_chunk* %63, %struct.malloc_tree_chunk** %71, align 8, !tbaa !43
  br label %if.end165

if.else132:                                       ; preds = %if.then114, %land.lhs.true119, %land.rhs
  tail call void %4() #8
  unreachable

if.else134:                                       ; preds = %if.then111
  %arrayidx136 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %v.4.lcssa, i64 0, i32 4, i64 1
  %73 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 4, i64 1
  %74 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %73, align 8, !tbaa !38
  %cmp137 = icmp eq %struct.malloc_tree_chunk* %74, null
  %75 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %74, i64 0, i32 0
  %76 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %75) #7
  %77 = bitcast i64* %76 to %struct.malloc_tree_chunk*
  br i1 %cmp137, label %lor.lhs.false, label %while.cond144

lor.lhs.false:                                    ; preds = %if.else134
  %arrayidx140 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %v.4.lcssa, i64 0, i32 4, i64 0
  %78 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 4, i64 0
  %79 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %78, align 8, !tbaa !38
  %cmp141 = icmp eq %struct.malloc_tree_chunk* %79, null
  %80 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %79, i64 0, i32 0
  %81 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %80) #7
  %82 = bitcast i64* %81 to %struct.malloc_tree_chunk*
  br i1 %cmp141, label %if.end165, label %while.cond144

while.cond144:                                    ; preds = %if.else134, %lor.lhs.false, %while.body153
  %RP.1 = phi %struct.malloc_tree_chunk** [ %CP.0, %while.body153 ], [ %arrayidx140, %lor.lhs.false ], [ %arrayidx136, %if.else134 ]
  %83 = phi %struct.malloc_tree_chunk** [ %CP.0, %while.body153 ], [ %78, %lor.lhs.false ], [ %73, %if.else134 ]
  %R.1 = phi %struct.malloc_tree_chunk* [ %89, %while.body153 ], [ %79, %lor.lhs.false ], [ %74, %if.else134 ]
  %84 = phi %struct.malloc_tree_chunk* [ %89, %while.body153 ], [ %82, %lor.lhs.false ], [ %77, %if.else134 ]
  %arrayidx146 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 1
  %85 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %84, i64 0, i32 4, i64 1
  %86 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %85, align 8, !tbaa !38
  %cmp147 = icmp eq %struct.malloc_tree_chunk* %86, null
  br i1 %cmp147, label %lor.rhs, label %while.body153

lor.rhs:                                          ; preds = %while.cond144
  %arrayidx150 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 0
  %87 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %84, i64 0, i32 4, i64 0
  %88 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %87, align 8, !tbaa !38
  %cmp151 = icmp eq %struct.malloc_tree_chunk* %88, null
  br i1 %cmp151, label %while.end154, label %while.body153

while.body153:                                    ; preds = %lor.rhs, %while.cond144
  %89 = phi %struct.malloc_tree_chunk* [ %86, %while.cond144 ], [ %88, %lor.rhs ]
  %CP.0 = phi %struct.malloc_tree_chunk** [ %arrayidx146, %while.cond144 ], [ %arrayidx150, %lor.rhs ]
  %90 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %89, i64 0, i32 0
  %91 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %90) #7
  br label %while.cond144

while.end154:                                     ; preds = %lor.rhs
  %92 = bitcast %struct.malloc_tree_chunk** %RP.1 to i8*
  %93 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp156 = icmp ugt i8* %93, %92
  br i1 %cmp156, label %if.else162, label %if.then161, !prof !34

if.then161:                                       ; preds = %while.end154
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %83, align 8, !tbaa !38
  br label %if.end165

if.else162:                                       ; preds = %while.end154
  tail call void %4() #8
  unreachable

if.end165:                                        ; preds = %if.then161, %lor.lhs.false, %if.then129
  %R.3 = phi %struct.malloc_tree_chunk* [ %57, %if.then129 ], [ null, %lor.lhs.false ], [ %R.1, %if.then161 ]
  %94 = phi %struct.malloc_tree_chunk* [ %57, %if.then129 ], [ %82, %lor.lhs.false ], [ %R.1, %if.then161 ]
  %cmp166 = icmp eq %struct.malloc_tree_chunk* %55, null
  br i1 %cmp166, label %if.end255, label %if.then168

if.then168:                                       ; preds = %if.end165
  %95 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 6
  %96 = load i32, i32* %95, align 8, !tbaa !44
  %idxprom170 = zext i32 %96 to i64
  %97 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %11, i64 0, i64 %idxprom170
  %98 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %97, align 8, !tbaa !38
  %cmp172 = icmp eq %struct.malloc_tree_chunk* %v.4.lcssa, %98
  br i1 %cmp172, label %if.then174, label %if.else183

if.then174:                                       ; preds = %if.then168
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %97, align 8, !tbaa !38
  %cond653 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cond653, label %if.end204.thread, label %if.then207

if.end204.thread:                                 ; preds = %if.then174
  %shl179 = shl i32 1, %96
  %neg = xor i32 %shl179, -1
  %99 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %8, i64 0, i32 1
  %100 = load i32, i32* %99, align 4, !tbaa !35
  %and181 = and i32 %100, %neg
  store i32 %and181, i32* %99, align 4, !tbaa !35
  br label %if.end255

if.else183:                                       ; preds = %if.then168
  %101 = bitcast %struct.malloc_tree_chunk* %55 to i8*
  %102 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp185 = icmp ugt i8* %102, %101
  br i1 %cmp185, label %if.else202, label %if.end204, !prof !34

if.else202:                                       ; preds = %if.else183
  tail call void %4() #8
  unreachable

if.end204:                                        ; preds = %if.else183
  %103 = getelementptr inbounds i64, i64* %59, i64 4
  %104 = bitcast i64* %103 to [2 x %struct.malloc_tree_chunk*]*
  %105 = bitcast i64* %103 to %struct.malloc_tree_chunk**
  %106 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %105, align 8, !tbaa !38
  %cmp193 = icmp ne %struct.malloc_tree_chunk* %106, %v.4.lcssa
  %.sink437 = zext i1 %cmp193 to i64
  %107 = getelementptr inbounds [2 x %struct.malloc_tree_chunk*], [2 x %struct.malloc_tree_chunk*]* %104, i64 0, i64 %.sink437
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %107, align 8, !tbaa !38
  %cmp205 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cmp205, label %if.end255, label %if.then207

if.then207:                                       ; preds = %if.then174, %if.end204
  %108 = bitcast %struct.malloc_tree_chunk* %R.3 to i8*
  %109 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp209 = icmp ugt i8* %109, %108
  br i1 %cmp209, label %if.else252, label %if.then214, !prof !34

if.then214:                                       ; preds = %if.then207
  %110 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %94, i64 0, i32 5
  store %struct.malloc_tree_chunk* %55, %struct.malloc_tree_chunk** %110, align 8, !tbaa !41
  %111 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 4, i64 0
  %112 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %111, align 8, !tbaa !38
  %cmp218 = icmp eq %struct.malloc_tree_chunk* %112, null
  %113 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %112, i64 0, i32 0
  %114 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %113) #7
  br i1 %cmp218, label %if.end233, label %if.then220

if.then220:                                       ; preds = %if.then214
  %115 = bitcast %struct.malloc_tree_chunk* %112 to i8*
  %116 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp222 = icmp ugt i8* %116, %115
  br i1 %cmp222, label %if.else231, label %if.then227, !prof !34

if.then227:                                       ; preds = %if.then220
  %117 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %94, i64 0, i32 4, i64 0
  store %struct.malloc_tree_chunk* %112, %struct.malloc_tree_chunk** %117, align 8, !tbaa !38
  %118 = getelementptr inbounds i64, i64* %114, i64 6
  %119 = bitcast i64* %118 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %119, align 8, !tbaa !41
  br label %if.end233

if.else231:                                       ; preds = %if.then220
  tail call void %4() #8
  unreachable

if.end233:                                        ; preds = %if.then214, %if.then227
  %120 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 4, i64 1
  %121 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %120, align 8, !tbaa !38
  %cmp236 = icmp eq %struct.malloc_tree_chunk* %121, null
  %122 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %121, i64 0, i32 0
  %123 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %122) #7
  br i1 %cmp236, label %if.end255, label %if.then238

if.then238:                                       ; preds = %if.end233
  %124 = bitcast %struct.malloc_tree_chunk* %121 to i8*
  %125 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp240 = icmp ugt i8* %125, %124
  br i1 %cmp240, label %if.else249, label %if.then245, !prof !34

if.then245:                                       ; preds = %if.then238
  %126 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %94, i64 0, i32 4, i64 1
  store %struct.malloc_tree_chunk* %121, %struct.malloc_tree_chunk** %126, align 8, !tbaa !38
  %127 = getelementptr inbounds i64, i64* %123, i64 6
  %128 = bitcast i64* %127 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %128, align 8, !tbaa !41
  br label %if.end255

if.else249:                                       ; preds = %if.then238
  tail call void %4() #8
  unreachable

if.else252:                                       ; preds = %if.then207
  tail call void %4() #8
  unreachable

if.end255:                                        ; preds = %if.end204.thread, %if.end204, %if.end233, %if.then245, %if.end165
  %cmp256 = icmp ult i64 %rsize.4.lcssa, 32
  br i1 %cmp256, label %if.then258, label %if.else267

if.then258:                                       ; preds = %if.end255
  %add259 = add i64 %rsize.4.lcssa, %nb
  %or261 = or i64 %add259, 3
  %129 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 1
  store i64 %or261, i64* %129, align 8, !tbaa !39
  %130 = getelementptr inbounds i8, i8* %49, i64 %add259
  %131 = getelementptr inbounds i8, i8* %130, i64 8
  %132 = bitcast i8* %131 to i64*
  %133 = load i64, i64* %132, align 8, !tbaa !11
  %or266 = or i64 %133, 1
  store i64 %or266, i64* %132, align 8, !tbaa !11
  br label %cleanup427

if.else267:                                       ; preds = %if.end255
  %or269 = or i64 %nb, 3
  %134 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %.lcssa663, i64 0, i32 1
  store i64 %or269, i64* %134, align 8, !tbaa !39
  %or271 = or i64 %rsize.4.lcssa, 1
  %135 = getelementptr inbounds i8, i8* %53, i64 8
  %136 = bitcast i8* %135 to i64*
  store i64 %or271, i64* %136, align 8, !tbaa !11
  %137 = getelementptr inbounds i8, i8* %53, i64 %rsize.4.lcssa
  %138 = bitcast i8* %137 to i64*
  store i64 %rsize.4.lcssa, i64* %138, align 8, !tbaa !32
  %cmp275 = icmp ult i64 %rsize.4.lcssa, 256
  br i1 %cmp275, label %if.then277, label %if.else308

if.then277:                                       ; preds = %if.else267
  %shr274 = lshr i64 %rsize.4.lcssa, 3
  %conv279 = trunc i64 %shr274 to i32
  %139 = getelementptr inbounds i64, i64* %7, i64 9
  %140 = bitcast i64* %139 to [66 x %struct.malloc_chunk*]*
  %shl280649 = shl nuw nsw i64 %shr274, 1
  %idxprom281 = and i64 %shl280649, 4294967294
  %arrayidx282 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom281
  %141 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %140, i64 0, i64 %idxprom281
  %142 = bitcast i64* %7 to i32*
  %143 = load i32, i32* %142, align 8, !tbaa !27
  %shl284 = shl i32 1, %conv279
  %and285 = and i32 %143, %shl284
  %tobool286 = icmp eq i32 %and285, 0
  br i1 %tobool286, label %if.then287, label %if.else291

if.then287:                                       ; preds = %if.then277
  %144 = bitcast %struct.malloc_chunk** %141 to %struct.malloc_chunk*
  %145 = bitcast %struct.malloc_chunk** %arrayidx282 to %struct.malloc_chunk*
  %or290 = or i32 %143, %shl284
  store i32 %or290, i32* %142, align 8, !tbaa !27
  %.pre = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %141, i64 2
  br label %if.end303

if.else291:                                       ; preds = %if.then277
  %146 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %141, i64 2
  %147 = load %struct.malloc_chunk*, %struct.malloc_chunk** %146, align 8, !tbaa !28
  %148 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %147, i64 0, i32 0
  %149 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %148) #7
  %150 = bitcast %struct.malloc_chunk* %147 to i8*
  %151 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp294 = icmp ugt i8* %151, %150
  br i1 %cmp294, label %if.else301, label %if.end303, !prof !34

if.else301:                                       ; preds = %if.else291
  tail call void %4() #8
  unreachable

if.end303:                                        ; preds = %if.else291, %if.then287
  %.pre-phi = phi %struct.malloc_chunk** [ %146, %if.else291 ], [ %.pre, %if.then287 ]
  %F283.0 = phi %struct.malloc_chunk* [ %147, %if.else291 ], [ %145, %if.then287 ]
  %152 = phi %struct.malloc_chunk* [ %147, %if.else291 ], [ %144, %if.then287 ]
  %153 = bitcast %struct.malloc_chunk** %.pre-phi to i8**
  store i8* %add.ptr, i8** %153, align 8, !tbaa !28
  %154 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %152, i64 0, i32 3
  %155 = bitcast %struct.malloc_chunk** %154 to i8**
  store i8* %add.ptr, i8** %155, align 8, !tbaa !29
  %156 = getelementptr inbounds i8, i8* %53, i64 16
  %157 = bitcast i8* %156 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %F283.0, %struct.malloc_chunk** %157, align 8, !tbaa !28
  %158 = getelementptr inbounds i8, i8* %53, i64 24
  %159 = bitcast i8* %158 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx282, %struct.malloc_chunk*** %159, align 8, !tbaa !29
  br label %cleanup427

if.else308:                                       ; preds = %if.else267
  %shr312 = lshr i64 %rsize.4.lcssa, 8
  %conv313 = trunc i64 %shr312 to i32
  %cmp314 = icmp eq i32 %conv313, 0
  br i1 %cmp314, label %if.end333, label %if.else317

if.else317:                                       ; preds = %if.else308
  %cmp318 = icmp ugt i32 %conv313, 65535
  br i1 %cmp318, label %if.end333, label %if.else321

if.else321:                                       ; preds = %if.else317
  %160 = tail call i32 @llvm.ctlz.i32(i32 %conv313, i1 true)
  %sub323 = xor i32 %160, 31
  %shl324 = shl nuw nsw i32 %sub323, 1
  %conv325 = zext i32 %shl324 to i64
  %add326 = add nuw nsw i32 %sub323, 7
  %sh_prom327 = zext i32 %add326 to i64
  %shr328 = lshr i64 %rsize.4.lcssa, %sh_prom327
  %and329 = and i64 %shr328, 1
  %add330 = or i64 %and329, %conv325
  %conv331 = trunc i64 %add330 to i32
  br label %if.end333

if.end333:                                        ; preds = %if.else317, %if.else308, %if.else321
  %I310.0 = phi i32 [ %conv331, %if.else321 ], [ 0, %if.else308 ], [ 31, %if.else317 ]
  %idxprom335 = zext i32 %I310.0 to i64
  %161 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %11, i64 0, i64 %idxprom335
  %162 = getelementptr inbounds i8, i8* %53, i64 56
  %163 = bitcast i8* %162 to i32*
  store i32 %I310.0, i32* %163, align 8, !tbaa !44
  %164 = getelementptr inbounds i8, i8* %53, i64 32
  %165 = bitcast i8* %164 to <2 x %struct.malloc_tree_chunk*>*
  store <2 x %struct.malloc_tree_chunk*> zeroinitializer, <2 x %struct.malloc_tree_chunk*>* %165, align 8, !tbaa !38
  %166 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %8, i64 0, i32 1
  %167 = load i32, i32* %166, align 4, !tbaa !35
  %shl343 = shl i32 1, %I310.0
  %and344 = and i32 %167, %shl343
  %tobool345 = icmp eq i32 %and344, 0
  br i1 %tobool345, label %if.then346, label %if.else353

if.then346:                                       ; preds = %if.end333
  %arrayidx336 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 11, i64 %idxprom335
  %or349 = or i32 %167, %shl343
  store i32 %or349, i32* %166, align 4, !tbaa !35
  %168 = bitcast %struct.malloc_tree_chunk** %161 to i8**
  store i8* %add.ptr, i8** %168, align 8, !tbaa !38
  %169 = getelementptr inbounds i8, i8* %53, i64 48
  %170 = bitcast i8* %169 to %struct.malloc_tree_chunk***
  store %struct.malloc_tree_chunk** %arrayidx336, %struct.malloc_tree_chunk*** %170, align 8, !tbaa !41
  %171 = getelementptr inbounds i8, i8* %53, i64 24
  %172 = bitcast i8* %171 to i8**
  store i8* %add.ptr, i8** %172, align 8, !tbaa !42
  %173 = getelementptr inbounds i8, i8* %53, i64 16
  %174 = bitcast i8* %173 to i8**
  store i8* %add.ptr, i8** %174, align 8, !tbaa !43
  br label %cleanup427

if.else353:                                       ; preds = %if.end333
  %175 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %161, align 8, !tbaa !38
  %cmp355 = icmp eq i32 %I310.0, 31
  %176 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %175, i64 0, i32 0
  %177 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %176) #7
  %178 = bitcast i64* %177 to %struct.malloc_tree_chunk*
  br i1 %cmp355, label %cond.end364, label %cond.false358

cond.false358:                                    ; preds = %if.else353
  %shr359 = lshr i32 %I310.0, 1
  %sub361 = add nuw i32 %shr359, 6
  %conv362 = zext i32 %sub361 to i64
  %sub363 = sub nsw i64 63, %conv362
  br label %cond.end364

cond.end364:                                      ; preds = %if.else353, %cond.false358
  %cond365 = phi i64 [ %sub363, %cond.false358 ], [ 0, %if.else353 ]
  %shl366 = shl i64 %rsize.4.lcssa, %cond365
  br label %for.cond367

for.cond367:                                      ; preds = %if.then372, %cond.end364
  %T.0 = phi %struct.malloc_tree_chunk* [ %175, %cond.end364 ], [ %183, %if.then372 ]
  %179 = phi %struct.malloc_tree_chunk* [ %178, %cond.end364 ], [ %183, %if.then372 ]
  %K354.0 = phi i64 [ %shl366, %cond.end364 ], [ %shl377, %if.then372 ]
  %180 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %179, i64 0, i32 1
  %181 = load i64, i64* %180, align 8, !tbaa !39
  %and369 = and i64 %181, -8
  %cmp370 = icmp eq i64 %and369, %rsize.4.lcssa
  br i1 %cmp370, label %if.else397, label %if.then372

if.then372:                                       ; preds = %for.cond367
  %shr374 = lshr i64 %K354.0, 63
  %182 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %179, i64 0, i32 4, i64 %shr374
  %shl377 = shl i64 %K354.0, 1
  %183 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %182, align 8, !tbaa !38
  %cmp378 = icmp eq %struct.malloc_tree_chunk* %183, null
  %184 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %183, i64 0, i32 0
  %185 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %184) #7
  br i1 %cmp378, label %if.else381, label %for.cond367

if.else381:                                       ; preds = %if.then372
  %arrayidx376 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %T.0, i64 0, i32 4, i64 %shr374
  %186 = bitcast %struct.malloc_tree_chunk** %arrayidx376 to i8*
  %187 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp383 = icmp ugt i8* %187, %186
  br i1 %cmp383, label %if.else392, label %cleanup394, !prof !34

if.else392:                                       ; preds = %if.else381
  tail call void %4() #8
  unreachable

cleanup394:                                       ; preds = %if.else381
  %188 = bitcast %struct.malloc_tree_chunk** %182 to i8**
  store i8* %add.ptr, i8** %188, align 8, !tbaa !38
  %189 = getelementptr inbounds i8, i8* %53, i64 48
  %190 = bitcast i8* %189 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %190, align 8, !tbaa !41
  %191 = getelementptr inbounds i8, i8* %53, i64 24
  %192 = bitcast i8* %191 to i8**
  store i8* %add.ptr, i8** %192, align 8, !tbaa !42
  %193 = getelementptr inbounds i8, i8* %53, i64 16
  %194 = bitcast i8* %193 to i8**
  store i8* %add.ptr, i8** %194, align 8, !tbaa !43
  br label %cleanup427

if.else397:                                       ; preds = %for.cond367
  %195 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %179, i64 0, i32 2
  %196 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %195, align 8, !tbaa !43
  %197 = bitcast %struct.malloc_tree_chunk* %T.0 to i8*
  %198 = load i8*, i8** %51, align 8, !tbaa !14
  %cmp401 = icmp ule i8* %198, %197
  %199 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %196, i64 0, i32 0
  %200 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %199) #7
  %201 = bitcast %struct.malloc_tree_chunk* %196 to i8*
  %cmp405 = icmp ule i8* %198, %201
  %202 = and i1 %cmp405, %cmp401
  br i1 %202, label %if.then412, label %if.else418, !prof !30

if.then412:                                       ; preds = %if.else397
  %203 = getelementptr inbounds i64, i64* %200, i64 3
  %204 = bitcast i64* %203 to i8**
  store i8* %add.ptr, i8** %204, align 8, !tbaa !42
  %205 = bitcast %struct.malloc_tree_chunk** %195 to i8**
  store i8* %add.ptr, i8** %205, align 8, !tbaa !43
  %206 = getelementptr inbounds i8, i8* %53, i64 16
  %207 = bitcast i8* %206 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %196, %struct.malloc_tree_chunk** %207, align 8, !tbaa !43
  %208 = getelementptr inbounds i8, i8* %53, i64 24
  %209 = bitcast i8* %208 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %209, align 8, !tbaa !42
  %210 = getelementptr inbounds i8, i8* %53, i64 48
  %211 = bitcast i8* %210 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %211, align 8, !tbaa !41
  br label %cleanup427

if.else418:                                       ; preds = %if.else397
  tail call void %4() #8
  unreachable

cleanup427:                                       ; preds = %if.then258, %if.end303, %if.then412, %if.then346, %cleanup394
  %add.ptr425 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %v.4.lcssa, i64 0, i32 2
  %212 = bitcast %struct.malloc_tree_chunk** %add.ptr425 to i8*
  br label %cleanup432

if.end430:                                        ; preds = %if.then105, %if.then101
  tail call void %4() #8
  unreachable

cleanup432:                                       ; preds = %if.then56, %cleanup427, %land.lhs.true97, %while.end
  %retval.1 = phi i8* [ %212, %cleanup427 ], [ null, %while.end ], [ null, %land.lhs.true97 ], [ null, %if.then56 ]
  ret i8* %retval.1
}

; Function Attrs: nounwind uwtable
define internal noalias i8* @sys_alloc(%struct.malloc_state* %m, i64 %nb) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*, %struct.malloc_chunk*, i64)* @init_top to i64*)) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* undef) #7
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32* ()* @__errno_location to i64*)) #7
  %3 = bitcast i64* %2 to i32* ()*
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %5 = bitcast %struct.malloc_state* %m to i64*
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %5) #7
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (%struct.malloc_state*, i64)* @mmap_alloc to i64*)) #7
  %8 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 ()* @init_mparams to i64*)) #7
  %9 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*)* @init_bins to i64*)) #7
  %10 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %11 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*, i8*, i64, i32)* @add_segment to i64*)) #7
  %12 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (%struct.malloc_state*, i8*, i8*, i64)* @prepend_alloc to i64*)) #7
  %13 = load i64, i64* %10, align 8, !tbaa !1
  %cmp = icmp eq i64 %13, 0
  br i1 %cmp, label %lor.rhs, label %if.end11

lor.rhs:                                          ; preds = %entry
  %14 = bitcast i64* %8 to i32 ()*
  %call = tail call i32 %14() #7
  br label %if.end11

if.end11:                                         ; preds = %lor.rhs, %entry
  %15 = getelementptr i64, i64* %10, i64 2
  %16 = load i64, i64* %15, align 8, !tbaa !45
  %sub = add i64 %nb, 95
  %add12 = add i64 %sub, %16
  %neg = sub i64 0, %16
  %and14 = and i64 %add12, %neg
  %cmp15 = icmp ugt i64 %and14, %nb
  br i1 %cmp15, label %if.end18, label %cleanup171

if.end18:                                         ; preds = %if.end11
  %17 = getelementptr inbounds i64, i64* %6, i64 109
  %18 = load i64, i64* %17, align 8, !tbaa !46
  %cmp19 = icmp eq i64 %18, 0
  br i1 %cmp19, label %if.end169, label %if.then21

if.then21:                                        ; preds = %if.end18
  %19 = getelementptr inbounds i64, i64* %6, i64 107
  %20 = load i64, i64* %19, align 8, !tbaa !19
  %add22 = add i64 %20, %and14
  %cmp24 = icmp ule i64 %add22, %20
  %cmp27 = icmp ugt i64 %add22, %18
  %or.cond = or i1 %cmp24, %cmp27
  br i1 %or.cond, label %cleanup171, label %if.end169

if.end169:                                        ; preds = %if.then21, %if.end18
  %call170 = tail call i32* %3() #4
  %21 = bitcast i32* %call170 to i64*
  %22 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %21) #7
  %23 = bitcast i64* %22 to i32*
  store i32 12, i32* %23, align 4, !tbaa !23
  br label %cleanup171

cleanup171:                                       ; preds = %if.then21, %if.end11, %if.end169
  ret i8* null
}

; Function Attrs: nounwind uwtable
define void @mspace_free(i8* %msp, i8* %mem) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i64 (%struct.malloc_state*)* @release_unused_segments to i64*)) #7
  %1 = bitcast i64* %0 to i64 (%struct.malloc_state*)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 (%struct.malloc_state*, i64)* @sys_trim to i64*)) #7
  %3 = bitcast i64* %2 to i32 (%struct.malloc_state*, i64)*
  %4 = bitcast i8* %msp to i64*
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %4) #7
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %7 = bitcast i64* %6 to void ()*
  %8 = bitcast i8* %mem to i64*
  %9 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %8) #7
  %cmp = icmp eq i8* %mem, null
  br i1 %cmp, label %if.end719, label %if.then

if.then:                                          ; preds = %entry
  %add.ptr = getelementptr inbounds i8, i8* %mem, i64 -16
  %10 = getelementptr inbounds i64, i64* %9, i64 -2
  %11 = bitcast i64* %10 to i8*
  %12 = bitcast i8* %add.ptr to %struct.malloc_chunk*
  %13 = bitcast i64* %10 to %struct.malloc_chunk*
  %14 = bitcast i8* %msp to %struct.malloc_state*
  %15 = bitcast i64* %5 to %struct.malloc_state*
  %16 = getelementptr inbounds i64, i64* %5, i64 3
  %17 = bitcast i64* %16 to i8**
  %18 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp1 = icmp ult i8* %add.ptr, %18
  br i1 %cmp1, label %erroraction, label %land.rhs

land.rhs:                                         ; preds = %if.then
  %19 = getelementptr inbounds i64, i64* %9, i64 -1
  %20 = load i64, i64* %19, align 8, !tbaa !11
  %and = and i64 %20, 3
  %cmp2 = icmp eq i64 %and, 1
  br i1 %cmp2, label %erroraction, label %if.then3, !prof !34

if.then3:                                         ; preds = %land.rhs
  %and5 = and i64 %20, -8
  %add.ptr6 = getelementptr inbounds i8, i8* %add.ptr, i64 %and5
  %21 = getelementptr inbounds i8, i8* %11, i64 %and5
  %22 = bitcast i8* %add.ptr6 to %struct.malloc_chunk*
  %and8 = and i64 %20, 1
  %tobool9 = icmp eq i64 %and8, 0
  br i1 %tobool9, label %if.then10, label %if.end251

if.then10:                                        ; preds = %if.then3
  %23 = load i64, i64* %10, align 8, !tbaa !32
  %cmp13 = icmp eq i64 %and, 0
  br i1 %cmp13, label %if.end719, label %if.else

if.else:                                          ; preds = %if.then10
  %idx.neg = sub i64 0, %23
  %add.ptr17 = getelementptr inbounds i8, i8* %add.ptr, i64 %idx.neg
  %24 = getelementptr inbounds i8, i8* %11, i64 %idx.neg
  %25 = bitcast i8* %add.ptr17 to %struct.malloc_chunk*
  %add18 = add i64 %23, %and5
  %cmp20 = icmp ult i8* %add.ptr17, %18
  br i1 %cmp20, label %erroraction, label %if.then25, !prof !34

if.then25:                                        ; preds = %if.else
  %26 = getelementptr inbounds i64, i64* %5, i64 4
  %27 = bitcast i64* %26 to %struct.malloc_chunk**
  %28 = load %struct.malloc_chunk*, %struct.malloc_chunk** %27, align 8, !tbaa !33
  %cmp26 = icmp eq %struct.malloc_chunk* %28, %25
  br i1 %cmp26, label %if.else232, label %if.then28

if.then28:                                        ; preds = %if.then25
  %cmp29 = icmp ult i64 %23, 256
  br i1 %cmp29, label %if.then31, label %if.else83

if.then31:                                        ; preds = %if.then28
  %shr = lshr i64 %23, 3
  %29 = getelementptr inbounds i8, i8* %24, i64 16
  %30 = bitcast i8* %29 to %struct.malloc_chunk**
  %31 = load %struct.malloc_chunk*, %struct.malloc_chunk** %30, align 8, !tbaa !28
  %32 = getelementptr inbounds i8, i8* %24, i64 24
  %33 = bitcast i8* %32 to %struct.malloc_chunk**
  %34 = load %struct.malloc_chunk*, %struct.malloc_chunk** %33, align 8, !tbaa !29
  %conv33 = trunc i64 %shr to i32
  %smallbins = getelementptr inbounds i8, i8* %msp, i64 72
  %35 = bitcast i8* %smallbins to [66 x %struct.malloc_chunk*]*
  %shl1058 = shl nuw nsw i64 %shr, 1
  %idxprom = and i64 %shl1058, 4294967294
  %arrayidx = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %35, i64 0, i64 %idxprom
  %36 = bitcast %struct.malloc_chunk** %arrayidx to %struct.malloc_chunk*
  %cmp34 = icmp eq %struct.malloc_chunk* %31, %36
  %37 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %31, i64 0, i32 0
  %38 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %37) #7
  %39 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %34, i64 0, i32 0
  %40 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %39) #7
  br i1 %cmp34, label %if.then48, label %lor.rhs

lor.rhs:                                          ; preds = %if.then31
  %41 = bitcast %struct.malloc_chunk* %31 to i8*
  %cmp37 = icmp ugt i8* %18, %41
  br i1 %cmp37, label %if.else81, label %land.rhs39

land.rhs39:                                       ; preds = %lor.rhs
  %42 = getelementptr inbounds i64, i64* %38, i64 3
  %43 = bitcast i64* %42 to %struct.malloc_chunk**
  %44 = load %struct.malloc_chunk*, %struct.malloc_chunk** %43, align 8, !tbaa !29
  %cmp41 = icmp eq %struct.malloc_chunk* %44, %25
  br i1 %cmp41, label %if.then48, label %if.else81, !prof !30

if.then48:                                        ; preds = %if.then31, %land.rhs39
  %cmp49 = icmp eq %struct.malloc_chunk* %34, %31
  br i1 %cmp49, label %if.then51, label %if.else54

if.then51:                                        ; preds = %if.then48
  %shl52 = shl i32 1, %conv33
  %neg = xor i32 %shl52, -1
  %45 = bitcast i64* %5 to i32*
  %46 = load i32, i32* %45, align 8, !tbaa !27
  %and53 = and i32 %46, %neg
  store i32 %and53, i32* %45, align 8, !tbaa !27
  br label %if.end251

if.else54:                                        ; preds = %if.then48
  %cmp59 = icmp eq %struct.malloc_chunk* %34, %36
  br i1 %cmp59, label %if.else54.if.then76_crit_edge, label %lor.rhs61

if.else54.if.then76_crit_edge:                    ; preds = %if.else54
  %.pre1093 = getelementptr inbounds i64, i64* %40, i64 2
  %.pre1095 = bitcast i64* %.pre1093 to %struct.malloc_chunk**
  br label %if.then76

lor.rhs61:                                        ; preds = %if.else54
  %47 = bitcast %struct.malloc_chunk* %34 to i8*
  %48 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp63 = icmp ugt i8* %48, %47
  br i1 %cmp63, label %if.else79, label %land.rhs65

land.rhs65:                                       ; preds = %lor.rhs61
  %49 = getelementptr inbounds i64, i64* %40, i64 2
  %50 = bitcast i64* %49 to %struct.malloc_chunk**
  %51 = load %struct.malloc_chunk*, %struct.malloc_chunk** %50, align 8, !tbaa !28
  %cmp67 = icmp eq %struct.malloc_chunk* %51, %25
  br i1 %cmp67, label %if.then76, label %if.else79, !prof !30

if.then76:                                        ; preds = %if.else54.if.then76_crit_edge, %land.rhs65
  %.pre-phi1096 = phi %struct.malloc_chunk** [ %.pre1095, %if.else54.if.then76_crit_edge ], [ %50, %land.rhs65 ]
  %52 = getelementptr inbounds i64, i64* %38, i64 3
  %53 = bitcast i64* %52 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %34, %struct.malloc_chunk** %53, align 8, !tbaa !29
  store %struct.malloc_chunk* %31, %struct.malloc_chunk** %.pre-phi1096, align 8, !tbaa !28
  br label %if.end251

if.else79:                                        ; preds = %lor.rhs61, %land.rhs65
  tail call void %7() #8
  unreachable

if.else81:                                        ; preds = %lor.rhs, %land.rhs39
  tail call void %7() #8
  unreachable

if.else83:                                        ; preds = %if.then28
  %54 = bitcast i8* %add.ptr17 to %struct.malloc_tree_chunk*
  %55 = getelementptr inbounds i8, i8* %24, i64 48
  %56 = bitcast i8* %55 to %struct.malloc_tree_chunk**
  %57 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %56, align 8, !tbaa !41
  %58 = getelementptr inbounds i8, i8* %24, i64 24
  %59 = bitcast i8* %58 to %struct.malloc_tree_chunk**
  %60 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %59, align 8, !tbaa !42
  %cmp85 = icmp eq %struct.malloc_tree_chunk* %60, %54
  %61 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %57, i64 0, i32 0
  %62 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %61) #7
  %63 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %60, i64 0, i32 0
  %64 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %63) #7
  br i1 %cmp85, label %if.else111, label %if.then87

if.then87:                                        ; preds = %if.else83
  %65 = getelementptr inbounds i8, i8* %24, i64 16
  %66 = bitcast i8* %65 to %struct.malloc_tree_chunk**
  %67 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %66, align 8, !tbaa !43
  %68 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %67, i64 0, i32 0
  %69 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %68) #7
  %70 = bitcast %struct.malloc_tree_chunk* %67 to i8*
  %cmp92 = icmp ugt i8* %18, %70
  br i1 %cmp92, label %if.else109, label %land.lhs.true

land.lhs.true:                                    ; preds = %if.then87
  %71 = getelementptr inbounds i64, i64* %69, i64 3
  %72 = bitcast i64* %71 to %struct.malloc_tree_chunk**
  %73 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %72, align 8, !tbaa !42
  %cmp95 = icmp eq %struct.malloc_tree_chunk* %73, %54
  br i1 %cmp95, label %land.rhs97, label %if.else109

land.rhs97:                                       ; preds = %land.lhs.true
  %74 = getelementptr inbounds i64, i64* %64, i64 2
  %75 = bitcast i64* %74 to %struct.malloc_tree_chunk**
  %76 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %75, align 8, !tbaa !43
  %cmp99 = icmp eq %struct.malloc_tree_chunk* %76, %54
  br i1 %cmp99, label %if.then106, label %if.else109, !prof !30

if.then106:                                       ; preds = %land.rhs97
  store %struct.malloc_tree_chunk* %60, %struct.malloc_tree_chunk** %72, align 8, !tbaa !42
  store %struct.malloc_tree_chunk* %67, %struct.malloc_tree_chunk** %75, align 8, !tbaa !43
  br label %if.end141

if.else109:                                       ; preds = %if.then87, %land.lhs.true, %land.rhs97
  tail call void %7() #8
  unreachable

if.else111:                                       ; preds = %if.else83
  %child = getelementptr inbounds i8, i8* %add.ptr17, i64 32
  %77 = getelementptr inbounds i8, i8* %24, i64 32
  %arrayidx112 = getelementptr inbounds i8, i8* %child, i64 8
  %78 = getelementptr inbounds i8, i8* %77, i64 8
  %79 = bitcast i8* %78 to %struct.malloc_tree_chunk**
  %80 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %79, align 8, !tbaa !38
  %cmp113 = icmp eq %struct.malloc_tree_chunk* %80, null
  %81 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %80, i64 0, i32 0
  %82 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %81) #7
  %83 = bitcast i64* %82 to %struct.malloc_tree_chunk*
  br i1 %cmp113, label %lor.lhs.false, label %if.then119

lor.lhs.false:                                    ; preds = %if.else111
  %84 = bitcast i8* %77 to %struct.malloc_tree_chunk**
  %85 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %84, align 8, !tbaa !38
  %cmp117 = icmp eq %struct.malloc_tree_chunk* %85, null
  %86 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %85, i64 0, i32 0
  %87 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %86) #7
  %88 = bitcast i64* %87 to %struct.malloc_tree_chunk*
  br i1 %cmp117, label %if.end141, label %if.then119

if.then119:                                       ; preds = %lor.lhs.false, %if.else111
  %RP.0.in = phi i8* [ %arrayidx112, %if.else111 ], [ %child, %lor.lhs.false ]
  %89 = phi %struct.malloc_tree_chunk** [ %79, %if.else111 ], [ %84, %lor.lhs.false ]
  %R.0 = phi %struct.malloc_tree_chunk* [ %80, %if.else111 ], [ %85, %lor.lhs.false ]
  %90 = phi %struct.malloc_tree_chunk* [ %83, %if.else111 ], [ %88, %lor.lhs.false ]
  %RP.0 = bitcast i8* %RP.0.in to %struct.malloc_tree_chunk**
  br label %while.cond

while.cond:                                       ; preds = %while.body, %if.then119
  %RP.1 = phi %struct.malloc_tree_chunk** [ %RP.0, %if.then119 ], [ %CP.0, %while.body ]
  %91 = phi %struct.malloc_tree_chunk** [ %89, %if.then119 ], [ %CP.0, %while.body ]
  %R.1 = phi %struct.malloc_tree_chunk* [ %R.0, %if.then119 ], [ %97, %while.body ]
  %92 = phi %struct.malloc_tree_chunk* [ %90, %if.then119 ], [ %97, %while.body ]
  %arrayidx121 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 1
  %93 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %92, i64 0, i32 4, i64 1
  %94 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %93, align 8, !tbaa !38
  %cmp122 = icmp eq %struct.malloc_tree_chunk* %94, null
  br i1 %cmp122, label %lor.rhs124, label %while.body

lor.rhs124:                                       ; preds = %while.cond
  %arrayidx126 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 0
  %95 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %92, i64 0, i32 4, i64 0
  %96 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %95, align 8, !tbaa !38
  %cmp127 = icmp eq %struct.malloc_tree_chunk* %96, null
  br i1 %cmp127, label %while.end, label %while.body

while.body:                                       ; preds = %lor.rhs124, %while.cond
  %97 = phi %struct.malloc_tree_chunk* [ %94, %while.cond ], [ %96, %lor.rhs124 ]
  %CP.0 = phi %struct.malloc_tree_chunk** [ %arrayidx121, %while.cond ], [ %arrayidx126, %lor.rhs124 ]
  %98 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %97, i64 0, i32 0
  %99 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %98) #7
  br label %while.cond

while.end:                                        ; preds = %lor.rhs124
  %100 = bitcast %struct.malloc_tree_chunk** %RP.1 to i8*
  %101 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp132 = icmp ugt i8* %101, %100
  br i1 %cmp132, label %if.else138, label %if.then137, !prof !34

if.then137:                                       ; preds = %while.end
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %91, align 8, !tbaa !38
  br label %if.end141

if.else138:                                       ; preds = %while.end
  tail call void %7() #8
  unreachable

if.end141:                                        ; preds = %if.then137, %lor.lhs.false, %if.then106
  %R.3 = phi %struct.malloc_tree_chunk* [ %60, %if.then106 ], [ %R.1, %if.then137 ], [ null, %lor.lhs.false ]
  %102 = phi %struct.malloc_tree_chunk* [ %60, %if.then106 ], [ %R.1, %if.then137 ], [ %88, %lor.lhs.false ]
  %cmp142 = icmp eq %struct.malloc_tree_chunk* %57, null
  br i1 %cmp142, label %if.end251, label %if.then144

if.then144:                                       ; preds = %if.end141
  %103 = getelementptr inbounds i64, i64* %5, i64 75
  %104 = bitcast i64* %103 to [32 x %struct.malloc_tree_chunk*]*
  %105 = getelementptr inbounds i8, i8* %24, i64 56
  %106 = bitcast i8* %105 to i32*
  %107 = load i32, i32* %106, align 8, !tbaa !44
  %idxprom145 = zext i32 %107 to i64
  %108 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %104, i64 0, i64 %idxprom145
  %109 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %108, align 8, !tbaa !38
  %cmp147 = icmp eq %struct.malloc_tree_chunk* %109, %54
  br i1 %cmp147, label %if.then149, label %if.else158

if.then149:                                       ; preds = %if.then144
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %108, align 8, !tbaa !38
  %cond1063 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cond1063, label %if.end179.thread, label %if.then182

if.end179.thread:                                 ; preds = %if.then149
  %shl154 = shl i32 1, %107
  %neg155 = xor i32 %shl154, -1
  %110 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %15, i64 0, i32 1
  %111 = load i32, i32* %110, align 4, !tbaa !35
  %and156 = and i32 %111, %neg155
  store i32 %and156, i32* %110, align 4, !tbaa !35
  br label %if.end251

if.else158:                                       ; preds = %if.then144
  %112 = bitcast %struct.malloc_tree_chunk* %57 to i8*
  %113 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp160 = icmp ugt i8* %113, %112
  br i1 %cmp160, label %if.else177, label %if.end179, !prof !34

if.else177:                                       ; preds = %if.else158
  tail call void %7() #8
  unreachable

if.end179:                                        ; preds = %if.else158
  %114 = getelementptr inbounds i64, i64* %62, i64 4
  %115 = bitcast i64* %114 to [2 x %struct.malloc_tree_chunk*]*
  %116 = bitcast i64* %114 to %struct.malloc_tree_chunk**
  %117 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %116, align 8, !tbaa !38
  %cmp168 = icmp ne %struct.malloc_tree_chunk* %117, %54
  %.sink = zext i1 %cmp168 to i64
  %118 = getelementptr inbounds [2 x %struct.malloc_tree_chunk*], [2 x %struct.malloc_tree_chunk*]* %115, i64 0, i64 %.sink
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %118, align 8, !tbaa !38
  %cmp180 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cmp180, label %if.end251, label %if.then182

if.then182:                                       ; preds = %if.then149, %if.end179
  %119 = bitcast %struct.malloc_tree_chunk* %R.3 to i8*
  %120 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp184 = icmp ugt i8* %120, %119
  br i1 %cmp184, label %if.else227, label %if.then189, !prof !34

if.then189:                                       ; preds = %if.then182
  %121 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %102, i64 0, i32 5
  store %struct.malloc_tree_chunk* %57, %struct.malloc_tree_chunk** %121, align 8, !tbaa !41
  %122 = getelementptr inbounds i8, i8* %24, i64 32
  %123 = bitcast i8* %122 to %struct.malloc_tree_chunk**
  %124 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %123, align 8, !tbaa !38
  %cmp193 = icmp eq %struct.malloc_tree_chunk* %124, null
  %125 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %124, i64 0, i32 0
  %126 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %125) #7
  br i1 %cmp193, label %if.end208, label %if.then195

if.then195:                                       ; preds = %if.then189
  %127 = bitcast %struct.malloc_tree_chunk* %124 to i8*
  %128 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp197 = icmp ugt i8* %128, %127
  br i1 %cmp197, label %if.else206, label %if.then202, !prof !34

if.then202:                                       ; preds = %if.then195
  %129 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %102, i64 0, i32 4, i64 0
  store %struct.malloc_tree_chunk* %124, %struct.malloc_tree_chunk** %129, align 8, !tbaa !38
  %130 = getelementptr inbounds i64, i64* %126, i64 6
  %131 = bitcast i64* %130 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %131, align 8, !tbaa !41
  br label %if.end208

if.else206:                                       ; preds = %if.then195
  tail call void %7() #8
  unreachable

if.end208:                                        ; preds = %if.then189, %if.then202
  %132 = getelementptr inbounds i8, i8* %122, i64 8
  %133 = bitcast i8* %132 to %struct.malloc_tree_chunk**
  %134 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %133, align 8, !tbaa !38
  %cmp211 = icmp eq %struct.malloc_tree_chunk* %134, null
  %135 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %134, i64 0, i32 0
  %136 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %135) #7
  br i1 %cmp211, label %if.end251, label %if.then213

if.then213:                                       ; preds = %if.end208
  %137 = bitcast %struct.malloc_tree_chunk* %134 to i8*
  %138 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp215 = icmp ugt i8* %138, %137
  br i1 %cmp215, label %if.else224, label %if.then220, !prof !34

if.then220:                                       ; preds = %if.then213
  %139 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %102, i64 0, i32 4, i64 1
  store %struct.malloc_tree_chunk* %134, %struct.malloc_tree_chunk** %139, align 8, !tbaa !38
  %140 = getelementptr inbounds i64, i64* %136, i64 6
  %141 = bitcast i64* %140 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %141, align 8, !tbaa !41
  br label %if.end251

if.else224:                                       ; preds = %if.then213
  tail call void %7() #8
  unreachable

if.else227:                                       ; preds = %if.then182
  tail call void %7() #8
  unreachable

if.else232:                                       ; preds = %if.then25
  %142 = getelementptr inbounds i8, i8* %21, i64 8
  %143 = bitcast i8* %142 to i64*
  %144 = load i64, i64* %143, align 8, !tbaa !11
  %and234 = and i64 %144, 3
  %cmp235 = icmp eq i64 %and234, 3
  br i1 %cmp235, label %cleanup714.thread1075, label %if.end251

cleanup714.thread1075:                            ; preds = %if.else232
  %145 = getelementptr inbounds i64, i64* %5, i64 1
  store i64 %add18, i64* %145, align 8, !tbaa !31
  %and239 = and i64 %144, -2
  store i64 %and239, i64* %143, align 8, !tbaa !11
  %or = or i64 %add18, 1
  %146 = getelementptr inbounds i8, i8* %24, i64 8
  %147 = bitcast i8* %146 to i64*
  store i64 %or, i64* %147, align 8, !tbaa !11
  %148 = bitcast i8* %21 to i64*
  store i64 %add18, i64* %148, align 8, !tbaa !32
  br label %if.end719

if.end251:                                        ; preds = %if.end179.thread, %if.else232, %if.then51, %if.then76, %if.end179, %if.end208, %if.then220, %if.end141, %if.then3
  %psize.1 = phi i64 [ %and5, %if.then3 ], [ %add18, %if.end141 ], [ %add18, %if.then220 ], [ %add18, %if.end208 ], [ %add18, %if.end179 ], [ %add18, %if.then76 ], [ %add18, %if.then51 ], [ %add18, %if.else232 ], [ %add18, %if.end179.thread ]
  %149 = phi i8* [ %add.ptr, %if.then3 ], [ %add.ptr17, %if.end141 ], [ %add.ptr17, %if.then220 ], [ %add.ptr17, %if.end208 ], [ %add.ptr17, %if.end179 ], [ %add.ptr17, %if.then76 ], [ %add.ptr17, %if.then51 ], [ %add.ptr17, %if.else232 ], [ %add.ptr17, %if.end179.thread ]
  %p.1 = phi %struct.malloc_chunk* [ %12, %if.then3 ], [ %25, %if.end141 ], [ %25, %if.then220 ], [ %25, %if.end208 ], [ %25, %if.end179 ], [ %25, %if.then76 ], [ %25, %if.then51 ], [ %25, %if.else232 ], [ %25, %if.end179.thread ]
  %150 = phi %struct.malloc_chunk* [ %13, %if.then3 ], [ %25, %if.end141 ], [ %25, %if.then220 ], [ %25, %if.end208 ], [ %25, %if.end179 ], [ %25, %if.then76 ], [ %25, %if.then51 ], [ %25, %if.else232 ], [ %25, %if.end179.thread ]
  %151 = bitcast %struct.malloc_chunk* %150 to i8*
  %cmp252 = icmp ult i8* %149, %add.ptr6
  br i1 %cmp252, label %land.rhs254, label %erroraction

land.rhs254:                                      ; preds = %if.end251
  %152 = getelementptr inbounds i8, i8* %21, i64 8
  %153 = bitcast i8* %152 to i64*
  %154 = load i64, i64* %153, align 8, !tbaa !11
  %and256 = and i64 %154, 1
  %tobool257 = icmp eq i64 %and256, 0
  br i1 %tobool257, label %erroraction, label %if.then263, !prof !34

if.then263:                                       ; preds = %land.rhs254
  %and265 = and i64 %154, 2
  %tobool266 = icmp eq i64 %and265, 0
  br i1 %tobool266, label %if.then267, label %if.else556

if.then267:                                       ; preds = %if.then263
  %155 = getelementptr inbounds i64, i64* %5, i64 5
  %156 = bitcast i64* %155 to %struct.malloc_chunk**
  %157 = load %struct.malloc_chunk*, %struct.malloc_chunk** %156, align 8, !tbaa !37
  %cmp268 = icmp eq %struct.malloc_chunk* %157, %22
  br i1 %cmp268, label %if.then270, label %if.else287

if.then270:                                       ; preds = %if.then267
  %158 = getelementptr inbounds i64, i64* %5, i64 2
  %159 = load i64, i64* %158, align 8, !tbaa !36
  %add271 = add i64 %159, %psize.1
  store i64 %add271, i64* %158, align 8, !tbaa !36
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %156, align 8, !tbaa !37
  %or273 = or i64 %add271, 1
  %160 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 1
  store i64 %or273, i64* %160, align 8, !tbaa !11
  %161 = getelementptr inbounds i64, i64* %5, i64 4
  %162 = bitcast i64* %161 to %struct.malloc_chunk**
  %163 = load %struct.malloc_chunk*, %struct.malloc_chunk** %162, align 8, !tbaa !33
  %cmp276 = icmp eq %struct.malloc_chunk* %p.1, %163
  br i1 %cmp276, label %if.then278, label %if.end281

if.then278:                                       ; preds = %if.then270
  store %struct.malloc_chunk* null, %struct.malloc_chunk** %162, align 8, !tbaa !33
  %164 = getelementptr inbounds i64, i64* %5, i64 1
  store i64 0, i64* %164, align 8, !tbaa !31
  br label %if.end281

if.end281:                                        ; preds = %if.then278, %if.then270
  %165 = getelementptr inbounds i64, i64* %5, i64 6
  %166 = load i64, i64* %165, align 8, !tbaa !47
  %cmp282 = icmp ugt i64 %add271, %166
  br i1 %cmp282, label %if.then284, label %if.end719

if.then284:                                       ; preds = %if.end281
  %call = tail call i32 %3(%struct.malloc_state* %14, i64 0) #7
  br label %if.end719

if.else287:                                       ; preds = %if.then267
  %167 = getelementptr inbounds i64, i64* %5, i64 4
  %168 = bitcast i64* %167 to %struct.malloc_chunk**
  %169 = load %struct.malloc_chunk*, %struct.malloc_chunk** %168, align 8, !tbaa !33
  %cmp289 = icmp eq %struct.malloc_chunk* %169, %22
  br i1 %cmp289, label %if.then291, label %if.else300

if.then291:                                       ; preds = %if.else287
  %170 = getelementptr inbounds i64, i64* %5, i64 1
  %171 = load i64, i64* %170, align 8, !tbaa !31
  %add293 = add i64 %171, %psize.1
  store i64 %add293, i64* %170, align 8, !tbaa !31
  %172 = bitcast i64* %167 to i8**
  store i8* %149, i8** %172, align 8, !tbaa !33
  %or295 = or i64 %add293, 1
  %173 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 1
  store i64 %or295, i64* %173, align 8, !tbaa !11
  %174 = getelementptr inbounds i8, i8* %151, i64 %add293
  %175 = bitcast i8* %174 to i64*
  store i64 %add293, i64* %175, align 8, !tbaa !32
  br label %if.end719

if.else300:                                       ; preds = %if.else287
  %and302 = and i64 %154, -8
  %add303 = add i64 %and302, %psize.1
  %cmp305 = icmp ult i64 %154, 256
  br i1 %cmp305, label %if.then307, label %if.else374

if.then307:                                       ; preds = %if.else300
  %shr304 = lshr i64 %154, 3
  %176 = getelementptr inbounds i8, i8* %21, i64 16
  %177 = bitcast i8* %176 to %struct.malloc_chunk**
  %178 = load %struct.malloc_chunk*, %struct.malloc_chunk** %177, align 8, !tbaa !28
  %179 = getelementptr inbounds i8, i8* %21, i64 24
  %180 = bitcast i8* %179 to %struct.malloc_chunk**
  %181 = load %struct.malloc_chunk*, %struct.malloc_chunk** %180, align 8, !tbaa !29
  %conv314 = trunc i64 %shr304 to i32
  %smallbins315 = getelementptr inbounds i8, i8* %msp, i64 72
  %182 = bitcast i8* %smallbins315 to [66 x %struct.malloc_chunk*]*
  %shl3161056 = shl nuw nsw i64 %shr304, 1
  %idxprom317 = and i64 %shl3161056, 4294967294
  %arrayidx318 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %182, i64 0, i64 %idxprom317
  %183 = bitcast %struct.malloc_chunk** %arrayidx318 to %struct.malloc_chunk*
  %cmp319 = icmp eq %struct.malloc_chunk* %178, %183
  %184 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %178, i64 0, i32 0
  %185 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %184) #7
  %186 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %181, i64 0, i32 0
  %187 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %186) #7
  br i1 %cmp319, label %if.then336, label %lor.rhs321

lor.rhs321:                                       ; preds = %if.then307
  %188 = bitcast %struct.malloc_chunk* %178 to i8*
  %189 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp323 = icmp ugt i8* %189, %188
  br i1 %cmp323, label %if.else372, label %land.rhs325

land.rhs325:                                      ; preds = %lor.rhs321
  %190 = getelementptr inbounds i64, i64* %185, i64 3
  %191 = bitcast i64* %190 to %struct.malloc_chunk**
  %192 = load %struct.malloc_chunk*, %struct.malloc_chunk** %191, align 8, !tbaa !29
  %cmp327 = icmp eq %struct.malloc_chunk* %192, %22
  br i1 %cmp327, label %if.then336, label %if.else372, !prof !30

if.then336:                                       ; preds = %if.then307, %land.rhs325
  %cmp337 = icmp eq %struct.malloc_chunk* %181, %178
  br i1 %cmp337, label %if.then339, label %if.else344

if.then339:                                       ; preds = %if.then336
  %shl340 = shl i32 1, %conv314
  %neg341 = xor i32 %shl340, -1
  %193 = bitcast i64* %5 to i32*
  %194 = load i32, i32* %193, align 8, !tbaa !27
  %and343 = and i32 %194, %neg341
  store i32 %and343, i32* %193, align 8, !tbaa !27
  br label %if.end540

if.else344:                                       ; preds = %if.then336
  %cmp349 = icmp eq %struct.malloc_chunk* %181, %183
  br i1 %cmp349, label %if.else344.if.then366_crit_edge, label %lor.rhs351

if.else344.if.then366_crit_edge:                  ; preds = %if.else344
  %.pre1089 = getelementptr inbounds i64, i64* %187, i64 2
  %.pre1091 = bitcast i64* %.pre1089 to %struct.malloc_chunk**
  br label %if.then366

lor.rhs351:                                       ; preds = %if.else344
  %195 = bitcast %struct.malloc_chunk* %181 to i8*
  %196 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp353 = icmp ugt i8* %196, %195
  br i1 %cmp353, label %if.else369, label %land.rhs355

land.rhs355:                                      ; preds = %lor.rhs351
  %197 = getelementptr inbounds i64, i64* %187, i64 2
  %198 = bitcast i64* %197 to %struct.malloc_chunk**
  %199 = load %struct.malloc_chunk*, %struct.malloc_chunk** %198, align 8, !tbaa !28
  %cmp357 = icmp eq %struct.malloc_chunk* %199, %22
  br i1 %cmp357, label %if.then366, label %if.else369, !prof !30

if.then366:                                       ; preds = %if.else344.if.then366_crit_edge, %land.rhs355
  %.pre-phi1092 = phi %struct.malloc_chunk** [ %.pre1091, %if.else344.if.then366_crit_edge ], [ %198, %land.rhs355 ]
  %200 = getelementptr inbounds i64, i64* %185, i64 3
  %201 = bitcast i64* %200 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %181, %struct.malloc_chunk** %201, align 8, !tbaa !29
  store %struct.malloc_chunk* %178, %struct.malloc_chunk** %.pre-phi1092, align 8, !tbaa !28
  br label %if.end540

if.else369:                                       ; preds = %lor.rhs351, %land.rhs355
  tail call void %7() #8
  unreachable

if.else372:                                       ; preds = %lor.rhs321, %land.rhs325
  tail call void %7() #8
  unreachable

if.else374:                                       ; preds = %if.else300
  %202 = bitcast i8* %add.ptr6 to %struct.malloc_tree_chunk*
  %203 = getelementptr inbounds i8, i8* %21, i64 48
  %204 = bitcast i8* %203 to %struct.malloc_tree_chunk**
  %205 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %204, align 8, !tbaa !41
  %206 = getelementptr inbounds i8, i8* %21, i64 24
  %207 = bitcast i8* %206 to %struct.malloc_tree_chunk**
  %208 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %207, align 8, !tbaa !42
  %cmp380 = icmp eq %struct.malloc_tree_chunk* %208, %202
  %209 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %205, i64 0, i32 0
  %210 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %209) #7
  %211 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %208, i64 0, i32 0
  %212 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %211) #7
  br i1 %cmp380, label %if.else407, label %if.then382

if.then382:                                       ; preds = %if.else374
  %213 = getelementptr inbounds i8, i8* %21, i64 16
  %214 = bitcast i8* %213 to %struct.malloc_tree_chunk**
  %215 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %214, align 8, !tbaa !43
  %216 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %215, i64 0, i32 0
  %217 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %216) #7
  %218 = bitcast %struct.malloc_tree_chunk* %215 to i8*
  %219 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp387 = icmp ugt i8* %219, %218
  br i1 %cmp387, label %if.else405, label %land.lhs.true389

land.lhs.true389:                                 ; preds = %if.then382
  %220 = getelementptr inbounds i64, i64* %217, i64 3
  %221 = bitcast i64* %220 to %struct.malloc_tree_chunk**
  %222 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %221, align 8, !tbaa !42
  %cmp391 = icmp eq %struct.malloc_tree_chunk* %222, %202
  br i1 %cmp391, label %land.rhs393, label %if.else405

land.rhs393:                                      ; preds = %land.lhs.true389
  %223 = getelementptr inbounds i64, i64* %212, i64 2
  %224 = bitcast i64* %223 to %struct.malloc_tree_chunk**
  %225 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %224, align 8, !tbaa !43
  %cmp395 = icmp eq %struct.malloc_tree_chunk* %225, %202
  br i1 %cmp395, label %if.then402, label %if.else405, !prof !30

if.then402:                                       ; preds = %land.rhs393
  store %struct.malloc_tree_chunk* %208, %struct.malloc_tree_chunk** %221, align 8, !tbaa !42
  store %struct.malloc_tree_chunk* %215, %struct.malloc_tree_chunk** %224, align 8, !tbaa !43
  br label %if.end444

if.else405:                                       ; preds = %if.then382, %land.lhs.true389, %land.rhs393
  tail call void %7() #8
  unreachable

if.else407:                                       ; preds = %if.else374
  %child409 = getelementptr inbounds i8, i8* %add.ptr6, i64 32
  %226 = getelementptr inbounds i8, i8* %21, i64 32
  %arrayidx410 = getelementptr inbounds i8, i8* %child409, i64 8
  %227 = getelementptr inbounds i8, i8* %226, i64 8
  %228 = bitcast i8* %227 to %struct.malloc_tree_chunk**
  %229 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %228, align 8, !tbaa !38
  %cmp411 = icmp eq %struct.malloc_tree_chunk* %229, null
  %230 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %229, i64 0, i32 0
  %231 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %230) #7
  %232 = bitcast i64* %231 to %struct.malloc_tree_chunk*
  br i1 %cmp411, label %lor.lhs.false413, label %if.then418

lor.lhs.false413:                                 ; preds = %if.else407
  %233 = bitcast i8* %226 to %struct.malloc_tree_chunk**
  %234 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %233, align 8, !tbaa !38
  %cmp416 = icmp eq %struct.malloc_tree_chunk* %234, null
  %235 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %234, i64 0, i32 0
  %236 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %235) #7
  %237 = bitcast i64* %236 to %struct.malloc_tree_chunk*
  br i1 %cmp416, label %if.end444, label %if.then418

if.then418:                                       ; preds = %lor.lhs.false413, %if.else407
  %RP408.0.in = phi i8* [ %arrayidx410, %if.else407 ], [ %child409, %lor.lhs.false413 ]
  %238 = phi %struct.malloc_tree_chunk** [ %228, %if.else407 ], [ %233, %lor.lhs.false413 ]
  %R378.0 = phi %struct.malloc_tree_chunk* [ %229, %if.else407 ], [ %234, %lor.lhs.false413 ]
  %239 = phi %struct.malloc_tree_chunk* [ %232, %if.else407 ], [ %237, %lor.lhs.false413 ]
  %RP408.0 = bitcast i8* %RP408.0.in to %struct.malloc_tree_chunk**
  br label %while.cond420

while.cond420:                                    ; preds = %while.body432, %if.then418
  %RP408.1 = phi %struct.malloc_tree_chunk** [ %RP408.0, %if.then418 ], [ %CP419.0, %while.body432 ]
  %240 = phi %struct.malloc_tree_chunk** [ %238, %if.then418 ], [ %CP419.0, %while.body432 ]
  %R378.1 = phi %struct.malloc_tree_chunk* [ %R378.0, %if.then418 ], [ %246, %while.body432 ]
  %241 = phi %struct.malloc_tree_chunk* [ %239, %if.then418 ], [ %246, %while.body432 ]
  %arrayidx422 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R378.1, i64 0, i32 4, i64 1
  %242 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %241, i64 0, i32 4, i64 1
  %243 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %242, align 8, !tbaa !38
  %cmp423 = icmp eq %struct.malloc_tree_chunk* %243, null
  br i1 %cmp423, label %lor.rhs425, label %while.body432

lor.rhs425:                                       ; preds = %while.cond420
  %arrayidx427 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R378.1, i64 0, i32 4, i64 0
  %244 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %241, i64 0, i32 4, i64 0
  %245 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %244, align 8, !tbaa !38
  %cmp428 = icmp eq %struct.malloc_tree_chunk* %245, null
  br i1 %cmp428, label %while.end433, label %while.body432

while.body432:                                    ; preds = %lor.rhs425, %while.cond420
  %246 = phi %struct.malloc_tree_chunk* [ %243, %while.cond420 ], [ %245, %lor.rhs425 ]
  %CP419.0 = phi %struct.malloc_tree_chunk** [ %arrayidx422, %while.cond420 ], [ %arrayidx427, %lor.rhs425 ]
  %247 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %246, i64 0, i32 0
  %248 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %247) #7
  br label %while.cond420

while.end433:                                     ; preds = %lor.rhs425
  %249 = bitcast %struct.malloc_tree_chunk** %RP408.1 to i8*
  %250 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp435 = icmp ugt i8* %250, %249
  br i1 %cmp435, label %if.else441, label %if.then440, !prof !34

if.then440:                                       ; preds = %while.end433
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %240, align 8, !tbaa !38
  br label %if.end444

if.else441:                                       ; preds = %while.end433
  tail call void %7() #8
  unreachable

if.end444:                                        ; preds = %if.then440, %lor.lhs.false413, %if.then402
  %R378.3 = phi %struct.malloc_tree_chunk* [ %208, %if.then402 ], [ null, %lor.lhs.false413 ], [ %R378.1, %if.then440 ]
  %251 = phi %struct.malloc_tree_chunk* [ %208, %if.then402 ], [ %237, %lor.lhs.false413 ], [ %R378.1, %if.then440 ]
  %cmp445 = icmp eq %struct.malloc_tree_chunk* %205, null
  br i1 %cmp445, label %if.end540, label %if.then447

if.then447:                                       ; preds = %if.end444
  %252 = getelementptr inbounds i64, i64* %5, i64 75
  %253 = bitcast i64* %252 to [32 x %struct.malloc_tree_chunk*]*
  %254 = getelementptr inbounds i8, i8* %21, i64 56
  %255 = bitcast i8* %254 to i32*
  %256 = load i32, i32* %255, align 8, !tbaa !44
  %idxprom451 = zext i32 %256 to i64
  %257 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %253, i64 0, i64 %idxprom451
  %258 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %257, align 8, !tbaa !38
  %cmp453 = icmp eq %struct.malloc_tree_chunk* %258, %202
  br i1 %cmp453, label %if.then455, label %if.else465

if.then455:                                       ; preds = %if.then447
  store %struct.malloc_tree_chunk* %R378.3, %struct.malloc_tree_chunk** %257, align 8, !tbaa !38
  %cond1064 = icmp eq %struct.malloc_tree_chunk* %R378.3, null
  br i1 %cond1064, label %if.end486.thread, label %if.then489

if.end486.thread:                                 ; preds = %if.then455
  %shl460 = shl i32 1, %256
  %neg461 = xor i32 %shl460, -1
  %259 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %15, i64 0, i32 1
  %260 = load i32, i32* %259, align 4, !tbaa !35
  %and463 = and i32 %260, %neg461
  store i32 %and463, i32* %259, align 4, !tbaa !35
  br label %if.end540

if.else465:                                       ; preds = %if.then447
  %261 = bitcast %struct.malloc_tree_chunk* %205 to i8*
  %262 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp467 = icmp ugt i8* %262, %261
  br i1 %cmp467, label %if.else484, label %if.end486, !prof !34

if.else484:                                       ; preds = %if.else465
  tail call void %7() #8
  unreachable

if.end486:                                        ; preds = %if.else465
  %263 = getelementptr inbounds i64, i64* %210, i64 4
  %264 = bitcast i64* %263 to [2 x %struct.malloc_tree_chunk*]*
  %265 = bitcast i64* %263 to %struct.malloc_tree_chunk**
  %266 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %265, align 8, !tbaa !38
  %cmp475 = icmp ne %struct.malloc_tree_chunk* %266, %202
  %.sink723 = zext i1 %cmp475 to i64
  %267 = getelementptr inbounds [2 x %struct.malloc_tree_chunk*], [2 x %struct.malloc_tree_chunk*]* %264, i64 0, i64 %.sink723
  store %struct.malloc_tree_chunk* %R378.3, %struct.malloc_tree_chunk** %267, align 8, !tbaa !38
  %cmp487 = icmp eq %struct.malloc_tree_chunk* %R378.3, null
  br i1 %cmp487, label %if.end540, label %if.then489

if.then489:                                       ; preds = %if.then455, %if.end486
  %268 = bitcast %struct.malloc_tree_chunk* %R378.3 to i8*
  %269 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp491 = icmp ugt i8* %269, %268
  br i1 %cmp491, label %if.else536, label %if.then496, !prof !34

if.then496:                                       ; preds = %if.then489
  %270 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %251, i64 0, i32 5
  store %struct.malloc_tree_chunk* %205, %struct.malloc_tree_chunk** %270, align 8, !tbaa !41
  %271 = getelementptr inbounds i8, i8* %21, i64 32
  %272 = bitcast i8* %271 to %struct.malloc_tree_chunk**
  %273 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %272, align 8, !tbaa !38
  %cmp502 = icmp eq %struct.malloc_tree_chunk* %273, null
  %274 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %273, i64 0, i32 0
  %275 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %274) #7
  br i1 %cmp502, label %if.end517, label %if.then504

if.then504:                                       ; preds = %if.then496
  %276 = bitcast %struct.malloc_tree_chunk* %273 to i8*
  %277 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp506 = icmp ugt i8* %277, %276
  br i1 %cmp506, label %if.else515, label %if.then511, !prof !34

if.then511:                                       ; preds = %if.then504
  %278 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %251, i64 0, i32 4, i64 0
  store %struct.malloc_tree_chunk* %273, %struct.malloc_tree_chunk** %278, align 8, !tbaa !38
  %279 = getelementptr inbounds i64, i64* %275, i64 6
  %280 = bitcast i64* %279 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R378.3, %struct.malloc_tree_chunk** %280, align 8, !tbaa !41
  br label %if.end517

if.else515:                                       ; preds = %if.then504
  tail call void %7() #8
  unreachable

if.end517:                                        ; preds = %if.then496, %if.then511
  %281 = getelementptr inbounds i8, i8* %271, i64 8
  %282 = bitcast i8* %281 to %struct.malloc_tree_chunk**
  %283 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %282, align 8, !tbaa !38
  %cmp520 = icmp eq %struct.malloc_tree_chunk* %283, null
  %284 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %283, i64 0, i32 0
  %285 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %284) #7
  br i1 %cmp520, label %if.end540, label %if.then522

if.then522:                                       ; preds = %if.end517
  %286 = bitcast %struct.malloc_tree_chunk* %283 to i8*
  %287 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp524 = icmp ugt i8* %287, %286
  br i1 %cmp524, label %if.else533, label %if.then529, !prof !34

if.then529:                                       ; preds = %if.then522
  %288 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %251, i64 0, i32 4, i64 1
  store %struct.malloc_tree_chunk* %283, %struct.malloc_tree_chunk** %288, align 8, !tbaa !38
  %289 = getelementptr inbounds i64, i64* %285, i64 6
  %290 = bitcast i64* %289 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R378.3, %struct.malloc_tree_chunk** %290, align 8, !tbaa !41
  br label %if.end540

if.else533:                                       ; preds = %if.then522
  tail call void %7() #8
  unreachable

if.else536:                                       ; preds = %if.then489
  tail call void %7() #8
  unreachable

if.end540:                                        ; preds = %if.end486.thread, %if.end444, %if.then529, %if.end517, %if.end486, %if.then366, %if.then339
  %or541 = or i64 %add303, 1
  %291 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 1
  store i64 %or541, i64* %291, align 8, !tbaa !11
  %292 = getelementptr inbounds i8, i8* %151, i64 %add303
  %293 = bitcast i8* %292 to i64*
  store i64 %add303, i64* %293, align 8, !tbaa !32
  %294 = load %struct.malloc_chunk*, %struct.malloc_chunk** %168, align 8, !tbaa !33
  %cmp546 = icmp eq %struct.malloc_chunk* %p.1, %294
  br i1 %cmp546, label %cleanup551, label %if.end563

cleanup551:                                       ; preds = %if.end540
  %295 = getelementptr inbounds i64, i64* %5, i64 1
  store i64 %add303, i64* %295, align 8, !tbaa !31
  br label %if.end719

if.else556:                                       ; preds = %if.then263
  %and558 = and i64 %154, -2
  store i64 %and558, i64* %153, align 8, !tbaa !11
  %or559 = or i64 %psize.1, 1
  %296 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 1
  store i64 %or559, i64* %296, align 8, !tbaa !11
  %297 = getelementptr inbounds i8, i8* %151, i64 %psize.1
  %298 = bitcast i8* %297 to i64*
  store i64 %psize.1, i64* %298, align 8, !tbaa !32
  br label %if.end563

if.end563:                                        ; preds = %if.end540, %if.else556
  %psize.2 = phi i64 [ %psize.1, %if.else556 ], [ %add303, %if.end540 ]
  %cmp565 = icmp ult i64 %psize.2, 256
  br i1 %cmp565, label %if.then567, label %if.else602

if.then567:                                       ; preds = %if.end563
  %shr564 = lshr i64 %psize.2, 3
  %conv570 = trunc i64 %shr564 to i32
  %smallbins572 = getelementptr inbounds i8, i8* %msp, i64 72
  %299 = bitcast i8* %smallbins572 to [66 x %struct.malloc_chunk*]*
  %300 = getelementptr inbounds i64, i64* %5, i64 9
  %301 = bitcast i64* %300 to [66 x %struct.malloc_chunk*]*
  %shl5731054 = shl nuw nsw i64 %shr564, 1
  %idxprom574 = and i64 %shl5731054, 4294967294
  %arrayidx575 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %299, i64 0, i64 %idxprom574
  %302 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %301, i64 0, i64 %idxprom574
  %303 = bitcast i64* %5 to i32*
  %304 = load i32, i32* %303, align 8, !tbaa !27
  %shl578 = shl i32 1, %conv570
  %and579 = and i32 %304, %shl578
  %tobool580 = icmp eq i32 %and579, 0
  br i1 %tobool580, label %if.then581, label %if.else585

if.then581:                                       ; preds = %if.then567
  %305 = bitcast %struct.malloc_chunk** %302 to %struct.malloc_chunk*
  %306 = bitcast %struct.malloc_chunk** %arrayidx575 to %struct.malloc_chunk*
  %or584 = or i32 %304, %shl578
  store i32 %or584, i32* %303, align 8, !tbaa !27
  %.pre = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %302, i64 2
  br label %if.end597

if.else585:                                       ; preds = %if.then567
  %307 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %302, i64 2
  %308 = load %struct.malloc_chunk*, %struct.malloc_chunk** %307, align 8, !tbaa !28
  %309 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %308, i64 0, i32 0
  %310 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %309) #7
  %311 = bitcast %struct.malloc_chunk* %308 to i8*
  %312 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp588 = icmp ugt i8* %312, %311
  br i1 %cmp588, label %if.else595, label %if.end597, !prof !34

if.else595:                                       ; preds = %if.else585
  tail call void %7() #8
  unreachable

if.end597:                                        ; preds = %if.else585, %if.then581
  %.pre-phi = phi %struct.malloc_chunk** [ %307, %if.else585 ], [ %.pre, %if.then581 ]
  %F576.0 = phi %struct.malloc_chunk* [ %308, %if.else585 ], [ %306, %if.then581 ]
  %313 = phi %struct.malloc_chunk* [ %308, %if.else585 ], [ %305, %if.then581 ]
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %.pre-phi, align 8, !tbaa !28
  %314 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %313, i64 0, i32 3
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %314, align 8, !tbaa !29
  %315 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 2
  store %struct.malloc_chunk* %F576.0, %struct.malloc_chunk** %315, align 8, !tbaa !28
  %316 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 3
  %317 = bitcast %struct.malloc_chunk** %316 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx575, %struct.malloc_chunk*** %317, align 8, !tbaa !29
  br label %if.end719

if.else602:                                       ; preds = %if.end563
  %shr605 = lshr i64 %psize.2, 8
  %conv606 = trunc i64 %shr605 to i32
  %cmp607 = icmp eq i32 %conv606, 0
  br i1 %cmp607, label %if.end623, label %if.else610

if.else610:                                       ; preds = %if.else602
  %cmp611 = icmp ugt i32 %conv606, 65535
  br i1 %cmp611, label %if.end623, label %if.else614

if.else614:                                       ; preds = %if.else610
  %318 = tail call i32 @llvm.ctlz.i32(i32 %conv606, i1 true)
  %sub = xor i32 %318, 31
  %shl615 = shl nuw nsw i32 %sub, 1
  %conv616 = zext i32 %shl615 to i64
  %add617 = add nuw nsw i32 %sub, 7
  %sh_prom = zext i32 %add617 to i64
  %shr618 = lshr i64 %psize.2, %sh_prom
  %and619 = and i64 %shr618, 1
  %add620 = or i64 %and619, %conv616
  %conv621 = trunc i64 %add620 to i32
  br label %if.end623

if.end623:                                        ; preds = %if.else610, %if.else602, %if.else614
  %I604.0 = phi i32 [ %conv621, %if.else614 ], [ 0, %if.else602 ], [ 31, %if.else610 ]
  %319 = getelementptr inbounds i64, i64* %5, i64 75
  %320 = bitcast i64* %319 to [32 x %struct.malloc_tree_chunk*]*
  %idxprom625 = zext i32 %I604.0 to i64
  %321 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %320, i64 0, i64 %idxprom625
  %322 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 1, i32 3
  %323 = bitcast %struct.malloc_chunk** %322 to i32*
  store i32 %I604.0, i32* %323, align 8, !tbaa !44
  %324 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 1
  %325 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %15, i64 0, i32 1
  %326 = bitcast %struct.malloc_chunk* %324 to i8*
  call void @llvm.memset.p0i8.i64(i8* %326, i8 0, i64 16, i32 8, i1 false)
  %327 = load i32, i32* %325, align 4, !tbaa !35
  %shl633 = shl i32 1, %I604.0
  %and634 = and i32 %327, %shl633
  %tobool635 = icmp eq i32 %and634, 0
  br i1 %tobool635, label %if.then636, label %if.else643

if.then636:                                       ; preds = %if.end623
  %treebins624 = getelementptr inbounds i8, i8* %msp, i64 600
  %328 = bitcast i8* %treebins624 to [32 x %struct.malloc_tree_chunk*]*
  %arrayidx626 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %328, i64 0, i64 %idxprom625
  %or639 = or i32 %327, %shl633
  store i32 %or639, i32* %325, align 4, !tbaa !35
  %329 = bitcast %struct.malloc_tree_chunk** %321 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %329, align 8, !tbaa !38
  %330 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 1, i32 2
  %331 = bitcast %struct.malloc_chunk** %330 to %struct.malloc_tree_chunk***
  store %struct.malloc_tree_chunk** %arrayidx626, %struct.malloc_tree_chunk*** %331, align 8, !tbaa !41
  %332 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 3
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %332, align 8, !tbaa !42
  %333 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 2
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %333, align 8, !tbaa !43
  br label %if.end706

if.else643:                                       ; preds = %if.end623
  %334 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %321, align 8, !tbaa !38
  %cmp645 = icmp eq i32 %I604.0, 31
  %335 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %334, i64 0, i32 0
  %336 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %335) #7
  %337 = bitcast i64* %336 to %struct.malloc_tree_chunk*
  br i1 %cmp645, label %cond.end, label %cond.false

cond.false:                                       ; preds = %if.else643
  %shr647 = lshr i32 %I604.0, 1
  %sub649 = add nuw i32 %shr647, 6
  %conv650 = zext i32 %sub649 to i64
  %sub651 = sub nsw i64 63, %conv650
  br label %cond.end

cond.end:                                         ; preds = %if.else643, %cond.false
  %cond = phi i64 [ %sub651, %cond.false ], [ 0, %if.else643 ]
  %shl652 = shl i64 %psize.2, %cond
  br label %for.cond

for.cond:                                         ; preds = %if.then657, %cond.end
  %T.0 = phi %struct.malloc_tree_chunk* [ %334, %cond.end ], [ %342, %if.then657 ]
  %338 = phi %struct.malloc_tree_chunk* [ %337, %cond.end ], [ %342, %if.then657 ]
  %K644.0 = phi i64 [ %shl652, %cond.end ], [ %shl662, %if.then657 ]
  %339 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %338, i64 0, i32 1
  %340 = load i64, i64* %339, align 8, !tbaa !39
  %and654 = and i64 %340, -8
  %cmp655 = icmp eq i64 %and654, %psize.2
  br i1 %cmp655, label %if.else682, label %if.then657

if.then657:                                       ; preds = %for.cond
  %shr659 = lshr i64 %K644.0, 63
  %341 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %338, i64 0, i32 4, i64 %shr659
  %shl662 = shl i64 %K644.0, 1
  %342 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %341, align 8, !tbaa !38
  %cmp663 = icmp eq %struct.malloc_tree_chunk* %342, null
  %343 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %342, i64 0, i32 0
  %344 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %343) #7
  br i1 %cmp663, label %if.else666, label %for.cond

if.else666:                                       ; preds = %if.then657
  %arrayidx661 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %T.0, i64 0, i32 4, i64 %shr659
  %345 = bitcast %struct.malloc_tree_chunk** %arrayidx661 to i8*
  %346 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp668 = icmp ugt i8* %346, %345
  br i1 %cmp668, label %if.else677, label %cleanup679, !prof !34

if.else677:                                       ; preds = %if.else666
  tail call void %7() #8
  unreachable

cleanup679:                                       ; preds = %if.else666
  %347 = bitcast %struct.malloc_tree_chunk** %341 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %347, align 8, !tbaa !38
  %348 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 1, i32 2
  %349 = bitcast %struct.malloc_chunk** %348 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %349, align 8, !tbaa !41
  %350 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 3
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %350, align 8, !tbaa !42
  %351 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 2
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %351, align 8, !tbaa !43
  br label %if.end706

if.else682:                                       ; preds = %for.cond
  %352 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %338, i64 0, i32 2
  %353 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %352, align 8, !tbaa !43
  %354 = bitcast %struct.malloc_tree_chunk* %T.0 to i8*
  %355 = load i8*, i8** %17, align 8, !tbaa !14
  %cmp686 = icmp ule i8* %355, %354
  %356 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %353, i64 0, i32 0
  %357 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %356) #7
  %358 = bitcast %struct.malloc_tree_chunk* %353 to i8*
  %cmp690 = icmp ule i8* %355, %358
  %359 = and i1 %cmp690, %cmp686
  br i1 %359, label %if.then697, label %if.else703, !prof !30

if.then697:                                       ; preds = %if.else682
  %360 = getelementptr inbounds i64, i64* %357, i64 3
  %361 = bitcast i64* %360 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %361, align 8, !tbaa !42
  %362 = bitcast %struct.malloc_tree_chunk** %352 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %p.1, %struct.malloc_chunk** %362, align 8, !tbaa !43
  %363 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 2
  %364 = bitcast %struct.malloc_chunk** %363 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %353, %struct.malloc_tree_chunk** %364, align 8, !tbaa !43
  %365 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 0, i32 3
  %366 = bitcast %struct.malloc_chunk** %365 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %366, align 8, !tbaa !42
  %367 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %150, i64 1, i32 2
  %368 = bitcast %struct.malloc_chunk** %367 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %368, align 8, !tbaa !41
  br label %if.end706

if.else703:                                       ; preds = %if.else682
  tail call void %7() #8
  unreachable

if.end706:                                        ; preds = %cleanup679, %if.then697, %if.then636
  %369 = getelementptr inbounds i64, i64* %5, i64 7
  %370 = load i64, i64* %369, align 8, !tbaa !22
  %dec = add i64 %370, -1
  store i64 %dec, i64* %369, align 8, !tbaa !22
  %cmp707 = icmp eq i64 %dec, 0
  br i1 %cmp707, label %if.then709, label %if.end719

if.then709:                                       ; preds = %if.end706
  %call710 = tail call i64 %1(%struct.malloc_state* %14) #7
  br label %if.end719

erroraction:                                      ; preds = %if.else, %land.rhs254, %land.rhs, %if.end251, %if.then
  tail call void %7() #8
  unreachable

if.end719:                                        ; preds = %if.then10, %if.end597, %if.then709, %if.end706, %if.end281, %if.then284, %cleanup551, %if.then291, %cleanup714.thread1075, %entry
  ret void
}

; Function Attrs: nounwind uwtable
define internal i32 @sys_trim(%struct.malloc_state* %m, i64 %pad) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*, %struct.malloc_chunk*, i64)* @init_top to i64*)) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (%struct.malloc_segment* (%struct.malloc_state*, i8*)* @segment_holding to i64*)) #7
  %2 = bitcast i64* %1 to %struct.malloc_segment* (%struct.malloc_state*, i8*)*
  %3 = bitcast %struct.malloc_state* %m to i64*
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %3) #7
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 ()* @init_mparams to i64*)) #7
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %7 = load i64, i64* %6, align 8, !tbaa !1
  %cmp = icmp eq i64 %7, 0
  br i1 %cmp, label %lor.rhs, label %lor.end

lor.rhs:                                          ; preds = %entry
  %8 = bitcast i64* %5 to i32 ()*
  %call = tail call i32 %8() #7
  br label %lor.end

lor.end:                                          ; preds = %entry, %lor.rhs
  %cmp1 = icmp ult i64 %pad, -128
  br i1 %cmp1, label %land.lhs.true, label %if.end37

land.lhs.true:                                    ; preds = %lor.end
  %9 = getelementptr inbounds i64, i64* %4, i64 5
  %10 = bitcast i64* %9 to %struct.malloc_chunk**
  %11 = load %struct.malloc_chunk*, %struct.malloc_chunk** %10, align 8, !tbaa !37
  %cmp2 = icmp eq %struct.malloc_chunk* %11, null
  %12 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %11, i64 0, i32 0
  %13 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %12) #7
  br i1 %cmp2, label %if.end37, label %if.then

if.then:                                          ; preds = %land.lhs.true
  %add = add i64 %pad, 80
  %14 = getelementptr inbounds i64, i64* %4, i64 2
  %15 = load i64, i64* %14, align 8, !tbaa !36
  %cmp3 = icmp ugt i64 %15, %add
  br i1 %cmp3, label %if.then4, label %land.lhs.true30

if.then4:                                         ; preds = %if.then
  %16 = bitcast %struct.malloc_chunk* %11 to i8*
  %call10 = tail call %struct.malloc_segment* %2(%struct.malloc_state* %m, i8* %16) #7
  %17 = bitcast %struct.malloc_segment* %call10 to i64*
  %18 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %17) #7
  %.pre = load i64, i64* %14, align 8, !tbaa !36
  br label %land.lhs.true30

land.lhs.true30:                                  ; preds = %if.then, %if.then4
  %19 = phi i64 [ %15, %if.then ], [ %.pre, %if.then4 ]
  %20 = getelementptr inbounds i64, i64* %4, i64 6
  %21 = load i64, i64* %20, align 8, !tbaa !47
  %cmp32 = icmp ugt i64 %19, %21
  br i1 %cmp32, label %if.then34, label %if.end37

if.then34:                                        ; preds = %land.lhs.true30
  store i64 -1, i64* %20, align 8, !tbaa !47
  br label %if.end37

if.end37:                                         ; preds = %land.lhs.true, %land.lhs.true30, %if.then34, %lor.end
  ret i32 0
}

; Function Attrs: nounwind readnone
declare i32 @llvm.ctlz.i32(i32, i1) #4

; Function Attrs: nounwind uwtable
define internal i64 @release_unused_segments(%struct.malloc_state* %m) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %1 = bitcast %struct.malloc_state* %m to i64*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %1) #7
  %3 = getelementptr inbounds i64, i64* %2, i64 113
  %4 = bitcast i64* %3 to %struct.malloc_segment**
  %5 = load %struct.malloc_segment*, %struct.malloc_segment** %4, align 8, !tbaa !26
  %6 = bitcast %struct.malloc_segment* %5 to i64*
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %6) #7
  %cmp424 = icmp eq %struct.malloc_segment* %5, null
  br i1 %cmp424, label %while.end270, label %while.body.preheader

while.body.preheader:                             ; preds = %entry
  %8 = bitcast i64* %7 to %struct.malloc_segment*
  br label %while.body

while.body:                                       ; preds = %while.body.preheader, %while.body
  %9 = phi %struct.malloc_segment* [ %13, %while.body ], [ %8, %while.body.preheader ]
  %10 = bitcast %struct.malloc_segment* %9 to i64**
  %11 = load i64*, i64** %10, align 8, !tbaa !48
  %12 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %9, i64 0, i32 2
  %13 = load %struct.malloc_segment*, %struct.malloc_segment** %12, align 8, !tbaa !26
  %14 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %11) #7
  %15 = bitcast %struct.malloc_segment* %13 to i64*
  %16 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %15) #7
  %cmp = icmp eq %struct.malloc_segment* %13, null
  br i1 %cmp, label %while.end270, label %while.body

while.end270:                                     ; preds = %while.body, %entry
  %17 = getelementptr inbounds i64, i64* %2, i64 7
  store i64 -1, i64* %17, align 8, !tbaa !22
  ret i64 0
}

; Function Attrs: nounwind uwtable
define i8* @mspace_calloc(i8* %msp, i64 %n_elements, i64 %elem_size) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64)* @mspace_malloc to i64*)) #7
  %1 = bitcast i64* %0 to i8* (i8*, i64)*
  %2 = bitcast i8* %msp to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %cmp = icmp eq i64 %n_elements, 0
  br i1 %cmp, label %if.end3, label %if.then

if.then:                                          ; preds = %entry
  %mul = mul i64 %elem_size, %n_elements
  %or = or i64 %elem_size, %n_elements
  %tobool = icmp ugt i64 %or, 65535
  br i1 %tobool, label %land.lhs.true, label %if.end3

land.lhs.true:                                    ; preds = %if.then
  %div = udiv i64 %mul, %n_elements
  %cmp1 = icmp eq i64 %div, %elem_size
  %mul. = select i1 %cmp1, i64 %mul, i64 -1
  br label %if.end3

if.end3:                                          ; preds = %land.lhs.true, %entry, %if.then
  %req.0 = phi i64 [ %mul, %if.then ], [ 0, %entry ], [ %mul., %land.lhs.true ]
  %call = tail call i8* %1(i8* %msp, i64 %req.0) #7
  %cmp4 = icmp eq i8* %call, null
  %4 = bitcast i8* %call to i64*
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %4) #7
  br i1 %cmp4, label %if.end9, label %land.lhs.true5

land.lhs.true5:                                   ; preds = %if.end3
  %6 = getelementptr inbounds i64, i64* %5, i64 -1
  %7 = load i64, i64* %6, align 8, !tbaa !11
  %and6 = and i64 %7, 3
  %cmp7 = icmp eq i64 %and6, 0
  br i1 %cmp7, label %if.end9, label %if.then8

if.then8:                                         ; preds = %land.lhs.true5
  %8 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %4) #7
  %9 = bitcast i64* %8 to i8*
  tail call void @llvm.memset.p0i8.i64(i8* %9, i8 0, i64 %req.0, i32 1, i1 false)
  br label %if.end9

if.end9:                                          ; preds = %if.end3, %if.then8, %land.lhs.true5
  ret i8* %call
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #2

; Function Attrs: nounwind uwtable
define i8* @mspace_realloc(i8* %msp, i8* %oldmem, i64 %bytes) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32* ()* @__errno_location to i64*)) #7
  %2 = bitcast i64* %1 to i32* ()*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (%struct.malloc_chunk* (%struct.malloc_state*, %struct.malloc_chunk*, i64, i32)* @try_realloc_chunk to i64*)) #7
  %4 = bitcast i64* %3 to %struct.malloc_chunk* (%struct.malloc_state*, %struct.malloc_chunk*, i64, i32)*
  %5 = bitcast i8* %msp to i64*
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %5) #7
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (i8*, i8*)* @mspace_free to i64*)) #7
  %8 = bitcast i64* %7 to void (i8*, i8*)*
  %9 = bitcast i8* %oldmem to i64*
  %10 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %9) #7
  %11 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64)* @mspace_malloc to i64*)) #7
  %12 = bitcast i64* %11 to i8* (i8*, i64)*
  %cmp = icmp eq i8* %oldmem, null
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = tail call i8* %12(i8* %msp, i64 %bytes) #7
  %13 = bitcast i8* %call to i64*
  %14 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %13) #7
  br label %if.end27

if.else:                                          ; preds = %entry
  %cmp1 = icmp ugt i64 %bytes, -129
  br i1 %cmp1, label %if.then2, label %if.else4

if.then2:                                         ; preds = %if.else
  %call3 = tail call i32* %2() #4
  %15 = bitcast i32* %call3 to i64*
  %16 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %15) #7
  %17 = bitcast i64* %16 to i32*
  store i32 12, i32* %17, align 4, !tbaa !23
  br label %if.end27

if.else4:                                         ; preds = %if.else
  %cmp5 = icmp ult i64 %bytes, 23
  %add6 = add i64 %bytes, 23
  %and = and i64 %add6, -16
  %cond = select i1 %cmp5, i64 32, i64 %and
  %add.ptr = getelementptr inbounds i8, i8* %oldmem, i64 -16
  %18 = bitcast i8* %add.ptr to %struct.malloc_chunk*
  %19 = bitcast i8* %msp to %struct.malloc_state*
  %call7 = tail call %struct.malloc_chunk* %4(%struct.malloc_state* %19, %struct.malloc_chunk* %18, i64 %cond, i32 1) #7
  %cmp8 = icmp eq %struct.malloc_chunk* %call7, null
  %20 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %call7, i64 0, i32 0
  %21 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %20) #7
  br i1 %cmp8, label %if.else11, label %if.then9

if.then9:                                         ; preds = %if.else4
  %add.ptr10 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %call7, i64 0, i32 2
  %22 = bitcast %struct.malloc_chunk** %add.ptr10 to i8*
  br label %if.end27

if.else11:                                        ; preds = %if.else4
  %call12 = tail call i8* %12(i8* %msp, i64 %bytes) #7
  %cmp13 = icmp eq i8* %call12, null
  %23 = bitcast i8* %call12 to i64*
  %24 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %23) #7
  br i1 %cmp13, label %if.end27, label %if.then14

if.then14:                                        ; preds = %if.else11
  %25 = bitcast i64* %24 to i8*
  %26 = getelementptr inbounds i64, i64* %10, i64 -1
  %27 = load i64, i64* %26, align 8, !tbaa !11
  %and15 = and i64 %27, -8
  %and17 = and i64 %27, 3
  %cmp18 = icmp eq i64 %and17, 0
  %cond19 = select i1 %cmp18, i64 16, i64 8
  %sub = sub i64 %and15, %cond19
  %cmp20 = icmp ult i64 %sub, %bytes
  %cond24 = select i1 %cmp20, i64 %sub, i64 %bytes
  %28 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %9) #7
  %29 = bitcast i64* %28 to i8*
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* %25, i8* %29, i64 %cond24, i32 1, i1 false)
  tail call void %8(i8* %msp, i8* nonnull %oldmem) #7
  br label %if.end27

if.end27:                                         ; preds = %if.then9, %if.then14, %if.else11, %if.then2, %if.then
  %mem.1 = phi i8* [ %call, %if.then ], [ null, %if.then2 ], [ %22, %if.then9 ], [ %call12, %if.then14 ], [ null, %if.else11 ]
  ret i8* %mem.1
}

; Function Attrs: nounwind readnone
declare i32* @__errno_location() #5

; Function Attrs: nounwind uwtable
define internal %struct.malloc_chunk* @try_realloc_chunk(%struct.malloc_state* %m, %struct.malloc_chunk* %p, i64 %nb, i32 %can_move) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (%struct.malloc_chunk* (%struct.malloc_state*, %struct.malloc_chunk*, i64, i32)* @mmap_resize to i64*)) #7
  %1 = bitcast i64* %0 to %struct.malloc_chunk* (%struct.malloc_state*, %struct.malloc_chunk*, i64, i32)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*, %struct.malloc_chunk*, i64)* @dispose_chunk to i64*)) #7
  %3 = bitcast i64* %2 to void (%struct.malloc_state*, %struct.malloc_chunk*, i64)*
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %5 = bitcast i64* %4 to void ()*
  %6 = bitcast %struct.malloc_state* %m to i64*
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %6) #7
  %8 = bitcast i64* %7 to %struct.malloc_state*
  %9 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %10 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %p, i64 0, i32 0
  %11 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %10) #7
  %12 = getelementptr inbounds i64, i64* %11, i64 1
  %13 = load i64, i64* %12, align 8, !tbaa !11
  %and = and i64 %13, -8
  %14 = bitcast %struct.malloc_chunk* %p to i8*
  %15 = bitcast i64* %11 to i8*
  %add.ptr = getelementptr inbounds i8, i8* %14, i64 %and
  %16 = getelementptr inbounds i8, i8* %15, i64 %and
  %17 = bitcast i8* %add.ptr to %struct.malloc_chunk*
  %18 = getelementptr inbounds i64, i64* %7, i64 3
  %19 = bitcast i64* %18 to i8**
  %20 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp = icmp ule i8* %20, %14
  %and2 = and i64 %13, 3
  %cmp3 = icmp ne i64 %and2, 1
  %or.cond.not = and i1 %cmp3, %cmp
  %cmp5 = icmp ugt i8* %add.ptr, %14
  %or.cond582 = and i1 %or.cond.not, %cmp5
  br i1 %or.cond582, label %land.rhs, label %if.else364

land.rhs:                                         ; preds = %entry
  %21 = getelementptr inbounds i8, i8* %16, i64 8
  %22 = bitcast i8* %21 to i64*
  %23 = load i64, i64* %22, align 8, !tbaa !11
  %and7 = and i64 %23, 1
  %tobool = icmp eq i64 %and7, 0
  br i1 %tobool, label %if.else364, label %if.then, !prof !34

if.then:                                          ; preds = %land.rhs
  %cmp11 = icmp eq i64 %and2, 0
  br i1 %cmp11, label %if.then13, label %if.else

if.then13:                                        ; preds = %if.then
  %call = tail call %struct.malloc_chunk* %1(%struct.malloc_state* %m, %struct.malloc_chunk* %p, i64 %nb, i32 %can_move) #7
  %24 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %call, i64 0, i32 0
  %25 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %24) #7
  br label %if.end365

if.else:                                          ; preds = %if.then
  %cmp14 = icmp ult i64 %and, %nb
  br i1 %cmp14, label %if.else36, label %if.then16

if.then16:                                        ; preds = %if.else
  %sub = sub i64 %and, %nb
  %cmp17 = icmp ugt i64 %sub, 31
  br i1 %cmp17, label %if.then19, label %if.end365

if.then19:                                        ; preds = %if.then16
  %add.ptr20 = getelementptr inbounds i8, i8* %14, i64 %nb
  %26 = getelementptr inbounds i8, i8* %15, i64 %nb
  %27 = bitcast i8* %add.ptr20 to %struct.malloc_chunk*
  %and22 = and i64 %13, 1
  %or = or i64 %and22, %nb
  %or23 = or i64 %or, 2
  store i64 %or23, i64* %12, align 8, !tbaa !11
  %28 = getelementptr inbounds i8, i8* %26, i64 8
  %29 = bitcast i8* %28 to i64*
  %or31 = or i64 %sub, 3
  store i64 %or31, i64* %29, align 8, !tbaa !11
  %30 = load i64, i64* %22, align 8, !tbaa !11
  %or35 = or i64 %30, 1
  store i64 %or35, i64* %22, align 8, !tbaa !11
  tail call void %3(%struct.malloc_state* %m, %struct.malloc_chunk* %27, i64 %sub) #7
  br label %if.end365

if.else36:                                        ; preds = %if.else
  %31 = getelementptr inbounds i64, i64* %7, i64 5
  %32 = bitcast i64* %31 to %struct.malloc_chunk**
  %33 = load %struct.malloc_chunk*, %struct.malloc_chunk** %32, align 8, !tbaa !37
  %cmp37 = icmp eq %struct.malloc_chunk* %33, %17
  br i1 %cmp37, label %if.then39, label %if.else60

if.then39:                                        ; preds = %if.else36
  %34 = getelementptr inbounds i64, i64* %7, i64 2
  %35 = load i64, i64* %34, align 8, !tbaa !36
  %add = add i64 %35, %and
  %cmp40 = icmp ugt i64 %add, %nb
  br i1 %cmp40, label %if.then42, label %if.end365

if.then42:                                        ; preds = %if.then39
  %sub45 = sub i64 %add, %nb
  %add.ptr46 = getelementptr inbounds i8, i8* %14, i64 %nb
  %36 = getelementptr inbounds i8, i8* %15, i64 %nb
  %and48 = and i64 %13, 1
  %or49 = or i64 %and48, %nb
  %or50 = or i64 %or49, 2
  store i64 %or50, i64* %12, align 8, !tbaa !11
  %37 = getelementptr inbounds i8, i8* %36, i64 8
  %38 = bitcast i8* %37 to i64*
  %or55 = or i64 %sub45, 1
  store i64 %or55, i64* %38, align 8, !tbaa !11
  %39 = bitcast i64* %31 to i8**
  store i8* %add.ptr46, i8** %39, align 8, !tbaa !37
  store i64 %sub45, i64* %34, align 8, !tbaa !36
  br label %if.end365

if.else60:                                        ; preds = %if.else36
  %40 = getelementptr inbounds i64, i64* %7, i64 4
  %41 = bitcast i64* %40 to %struct.malloc_chunk**
  %42 = load %struct.malloc_chunk*, %struct.malloc_chunk** %41, align 8, !tbaa !33
  %cmp61 = icmp eq %struct.malloc_chunk* %42, %17
  br i1 %cmp61, label %if.then63, label %if.else106

if.then63:                                        ; preds = %if.else60
  %43 = getelementptr inbounds i64, i64* %7, i64 1
  %44 = load i64, i64* %43, align 8, !tbaa !31
  %add64 = add i64 %44, %and
  %cmp65 = icmp ult i64 %add64, %nb
  br i1 %cmp65, label %if.end365, label %if.then67

if.then67:                                        ; preds = %if.then63
  %sub69 = sub i64 %add64, %nb
  %cmp70 = icmp ugt i64 %sub69, 31
  br i1 %cmp70, label %if.then72, label %if.else91

if.then72:                                        ; preds = %if.then67
  %add.ptr74 = getelementptr inbounds i8, i8* %14, i64 %nb
  %45 = getelementptr inbounds i8, i8* %15, i64 %nb
  %46 = bitcast i8* %add.ptr74 to %struct.malloc_chunk*
  %47 = getelementptr inbounds i8, i8* %15, i64 %add64
  %and77 = and i64 %13, 1
  %or78 = or i64 %and77, %nb
  %or79 = or i64 %or78, 2
  store i64 %or79, i64* %12, align 8, !tbaa !11
  %48 = getelementptr inbounds i8, i8* %45, i64 8
  %49 = bitcast i8* %48 to i64*
  %or84 = or i64 %sub69, 1
  store i64 %or84, i64* %49, align 8, !tbaa !11
  %50 = bitcast i8* %47 to i64*
  store i64 %sub69, i64* %50, align 8, !tbaa !32
  %51 = getelementptr inbounds i8, i8* %47, i64 8
  %52 = bitcast i8* %51 to i64*
  %53 = load i64, i64* %52, align 8, !tbaa !11
  %and88 = and i64 %53, -2
  store i64 %and88, i64* %52, align 8, !tbaa !11
  br label %if.end104

if.else91:                                        ; preds = %if.then67
  %and95 = and i64 %13, 1
  %or96 = or i64 %and95, %add64
  %or97 = or i64 %or96, 2
  store i64 %or97, i64* %12, align 8, !tbaa !11
  %54 = getelementptr inbounds i8, i8* %15, i64 %add64
  %55 = getelementptr inbounds i8, i8* %54, i64 8
  %56 = bitcast i8* %55 to i64*
  %57 = load i64, i64* %56, align 8, !tbaa !11
  %or101 = or i64 %57, 1
  store i64 %or101, i64* %56, align 8, !tbaa !11
  br label %if.end104

if.end104:                                        ; preds = %if.else91, %if.then72
  %storemerge581 = phi i64 [ %sub69, %if.then72 ], [ 0, %if.else91 ]
  %storemerge = phi %struct.malloc_chunk* [ %46, %if.then72 ], [ null, %if.else91 ]
  store i64 %storemerge581, i64* %43, align 8, !tbaa !31
  store %struct.malloc_chunk* %storemerge, %struct.malloc_chunk** %41, align 8, !tbaa !33
  br label %if.end365

if.else106:                                       ; preds = %if.else60
  %and108 = and i64 %23, 2
  %tobool109 = icmp eq i64 %and108, 0
  br i1 %tobool109, label %if.then110, label %if.end365

if.then110:                                       ; preds = %if.else106
  %and112 = and i64 %23, -8
  %add113 = add i64 %and112, %and
  %cmp114 = icmp ult i64 %add113, %nb
  br i1 %cmp114, label %if.end365, label %if.then116

if.then116:                                       ; preds = %if.then110
  %sub119 = sub i64 %add113, %nb
  %cmp120 = icmp ult i64 %23, 256
  br i1 %cmp120, label %if.then122, label %if.else175

if.then122:                                       ; preds = %if.then116
  %shr = lshr i64 %23, 3
  %58 = getelementptr inbounds i8, i8* %16, i64 16
  %59 = bitcast i8* %58 to %struct.malloc_chunk**
  %60 = load %struct.malloc_chunk*, %struct.malloc_chunk** %59, align 8, !tbaa !28
  %61 = getelementptr inbounds i8, i8* %16, i64 24
  %62 = bitcast i8* %61 to %struct.malloc_chunk**
  %63 = load %struct.malloc_chunk*, %struct.malloc_chunk** %62, align 8, !tbaa !29
  %conv124 = trunc i64 %shr to i32
  %shl577 = shl nuw nsw i64 %shr, 1
  %idxprom = and i64 %shl577, 4294967294
  %arrayidx = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom
  %64 = bitcast %struct.malloc_chunk** %arrayidx to %struct.malloc_chunk*
  %cmp125 = icmp eq %struct.malloc_chunk* %60, %64
  %65 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %60, i64 0, i32 0
  %66 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %65) #7
  %67 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %63, i64 0, i32 0
  %68 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %67) #7
  br i1 %cmp125, label %if.then139, label %lor.rhs

lor.rhs:                                          ; preds = %if.then122
  %69 = bitcast %struct.malloc_chunk* %60 to i8*
  %70 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp128 = icmp ugt i8* %70, %69
  br i1 %cmp128, label %if.else173, label %land.rhs130

land.rhs130:                                      ; preds = %lor.rhs
  %71 = getelementptr inbounds i64, i64* %66, i64 3
  %72 = bitcast i64* %71 to %struct.malloc_chunk**
  %73 = load %struct.malloc_chunk*, %struct.malloc_chunk** %72, align 8, !tbaa !29
  %cmp132 = icmp eq %struct.malloc_chunk* %73, %17
  br i1 %cmp132, label %if.then139, label %if.else173, !prof !30

if.then139:                                       ; preds = %if.then122, %land.rhs130
  %cmp140 = icmp eq %struct.malloc_chunk* %63, %60
  br i1 %cmp140, label %if.then142, label %if.else145

if.then142:                                       ; preds = %if.then139
  %shl143 = shl i32 1, %conv124
  %neg = xor i32 %shl143, -1
  %74 = bitcast i64* %7 to i32*
  %75 = load i32, i32* %74, align 8, !tbaa !27
  %and144 = and i32 %75, %neg
  store i32 %and144, i32* %74, align 8, !tbaa !27
  br label %if.end324

if.else145:                                       ; preds = %if.then139
  %cmp150 = icmp eq %struct.malloc_chunk* %63, %64
  br i1 %cmp150, label %if.else145.if.then167_crit_edge, label %lor.rhs152

if.else145.if.then167_crit_edge:                  ; preds = %if.else145
  %.pre = getelementptr inbounds i64, i64* %68, i64 2
  %.pre584 = bitcast i64* %.pre to %struct.malloc_chunk**
  br label %if.then167

lor.rhs152:                                       ; preds = %if.else145
  %76 = bitcast %struct.malloc_chunk* %63 to i8*
  %77 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp154 = icmp ugt i8* %77, %76
  br i1 %cmp154, label %if.else170, label %land.rhs156

land.rhs156:                                      ; preds = %lor.rhs152
  %78 = getelementptr inbounds i64, i64* %68, i64 2
  %79 = bitcast i64* %78 to %struct.malloc_chunk**
  %80 = load %struct.malloc_chunk*, %struct.malloc_chunk** %79, align 8, !tbaa !28
  %cmp158 = icmp eq %struct.malloc_chunk* %80, %17
  br i1 %cmp158, label %if.then167, label %if.else170, !prof !30

if.then167:                                       ; preds = %if.else145.if.then167_crit_edge, %land.rhs156
  %.pre-phi585 = phi %struct.malloc_chunk** [ %.pre584, %if.else145.if.then167_crit_edge ], [ %79, %land.rhs156 ]
  %81 = getelementptr inbounds i64, i64* %66, i64 3
  %82 = bitcast i64* %81 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %63, %struct.malloc_chunk** %82, align 8, !tbaa !29
  store %struct.malloc_chunk* %60, %struct.malloc_chunk** %.pre-phi585, align 8, !tbaa !28
  br label %if.end324

if.else170:                                       ; preds = %lor.rhs152, %land.rhs156
  tail call void %5() #8
  unreachable

if.else173:                                       ; preds = %lor.rhs, %land.rhs130
  tail call void %5() #8
  unreachable

if.else175:                                       ; preds = %if.then116
  %83 = bitcast i8* %add.ptr to %struct.malloc_tree_chunk*
  %84 = getelementptr inbounds i8, i8* %16, i64 48
  %85 = bitcast i8* %84 to %struct.malloc_tree_chunk**
  %86 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %85, align 8, !tbaa !41
  %87 = getelementptr inbounds i8, i8* %16, i64 24
  %88 = bitcast i8* %87 to %struct.malloc_tree_chunk**
  %89 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %88, align 8, !tbaa !42
  %cmp177 = icmp eq %struct.malloc_tree_chunk* %89, %83
  %90 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %86, i64 0, i32 0
  %91 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %90) #7
  %92 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %89, i64 0, i32 0
  %93 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %92) #7
  br i1 %cmp177, label %if.else204, label %if.then179

if.then179:                                       ; preds = %if.else175
  %94 = getelementptr inbounds i8, i8* %16, i64 16
  %95 = bitcast i8* %94 to %struct.malloc_tree_chunk**
  %96 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %95, align 8, !tbaa !43
  %97 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %96, i64 0, i32 0
  %98 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %97) #7
  %99 = bitcast %struct.malloc_tree_chunk* %96 to i8*
  %100 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp184 = icmp ugt i8* %100, %99
  br i1 %cmp184, label %if.else202, label %land.lhs.true186

land.lhs.true186:                                 ; preds = %if.then179
  %101 = getelementptr inbounds i64, i64* %98, i64 3
  %102 = bitcast i64* %101 to %struct.malloc_tree_chunk**
  %103 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %102, align 8, !tbaa !42
  %cmp188 = icmp eq %struct.malloc_tree_chunk* %103, %83
  br i1 %cmp188, label %land.rhs190, label %if.else202

land.rhs190:                                      ; preds = %land.lhs.true186
  %104 = getelementptr inbounds i64, i64* %93, i64 2
  %105 = bitcast i64* %104 to %struct.malloc_tree_chunk**
  %106 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %105, align 8, !tbaa !43
  %cmp192 = icmp eq %struct.malloc_tree_chunk* %106, %83
  br i1 %cmp192, label %if.then199, label %if.else202, !prof !30

if.then199:                                       ; preds = %land.rhs190
  store %struct.malloc_tree_chunk* %89, %struct.malloc_tree_chunk** %102, align 8, !tbaa !42
  store %struct.malloc_tree_chunk* %96, %struct.malloc_tree_chunk** %105, align 8, !tbaa !43
  br label %if.end234

if.else202:                                       ; preds = %if.then179, %land.lhs.true186, %land.rhs190
  tail call void %5() #8
  unreachable

if.else204:                                       ; preds = %if.else175
  %child = getelementptr inbounds i8, i8* %add.ptr, i64 32
  %107 = getelementptr inbounds i8, i8* %16, i64 32
  %arrayidx205 = getelementptr inbounds i8, i8* %child, i64 8
  %108 = getelementptr inbounds i8, i8* %107, i64 8
  %109 = bitcast i8* %108 to %struct.malloc_tree_chunk**
  %110 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %109, align 8, !tbaa !38
  %cmp206 = icmp eq %struct.malloc_tree_chunk* %110, null
  %111 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %110, i64 0, i32 0
  %112 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %111) #7
  %113 = bitcast i64* %112 to %struct.malloc_tree_chunk*
  br i1 %cmp206, label %lor.lhs.false, label %if.then212

lor.lhs.false:                                    ; preds = %if.else204
  %114 = bitcast i8* %107 to %struct.malloc_tree_chunk**
  %115 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %114, align 8, !tbaa !38
  %cmp210 = icmp eq %struct.malloc_tree_chunk* %115, null
  %116 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %115, i64 0, i32 0
  %117 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %116) #7
  %118 = bitcast i64* %117 to %struct.malloc_tree_chunk*
  br i1 %cmp210, label %if.end234, label %if.then212

if.then212:                                       ; preds = %lor.lhs.false, %if.else204
  %RP.0.in = phi i8* [ %arrayidx205, %if.else204 ], [ %child, %lor.lhs.false ]
  %119 = phi %struct.malloc_tree_chunk** [ %109, %if.else204 ], [ %114, %lor.lhs.false ]
  %R.0 = phi %struct.malloc_tree_chunk* [ %110, %if.else204 ], [ %115, %lor.lhs.false ]
  %120 = phi %struct.malloc_tree_chunk* [ %113, %if.else204 ], [ %118, %lor.lhs.false ]
  %RP.0 = bitcast i8* %RP.0.in to %struct.malloc_tree_chunk**
  br label %while.cond

while.cond:                                       ; preds = %while.body, %if.then212
  %RP.1 = phi %struct.malloc_tree_chunk** [ %RP.0, %if.then212 ], [ %CP.0, %while.body ]
  %121 = phi %struct.malloc_tree_chunk** [ %119, %if.then212 ], [ %CP.0, %while.body ]
  %R.1 = phi %struct.malloc_tree_chunk* [ %R.0, %if.then212 ], [ %127, %while.body ]
  %122 = phi %struct.malloc_tree_chunk* [ %120, %if.then212 ], [ %127, %while.body ]
  %arrayidx214 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 1
  %123 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %122, i64 0, i32 4, i64 1
  %124 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %123, align 8, !tbaa !38
  %cmp215 = icmp eq %struct.malloc_tree_chunk* %124, null
  br i1 %cmp215, label %lor.rhs217, label %while.body

lor.rhs217:                                       ; preds = %while.cond
  %arrayidx219 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 0
  %125 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %122, i64 0, i32 4, i64 0
  %126 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %125, align 8, !tbaa !38
  %cmp220 = icmp eq %struct.malloc_tree_chunk* %126, null
  br i1 %cmp220, label %while.end, label %while.body

while.body:                                       ; preds = %lor.rhs217, %while.cond
  %127 = phi %struct.malloc_tree_chunk* [ %124, %while.cond ], [ %126, %lor.rhs217 ]
  %CP.0 = phi %struct.malloc_tree_chunk** [ %arrayidx214, %while.cond ], [ %arrayidx219, %lor.rhs217 ]
  %128 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %127, i64 0, i32 0
  %129 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %128) #7
  br label %while.cond

while.end:                                        ; preds = %lor.rhs217
  %130 = bitcast %struct.malloc_tree_chunk** %RP.1 to i8*
  %131 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp225 = icmp ugt i8* %131, %130
  br i1 %cmp225, label %if.else231, label %if.then230, !prof !34

if.then230:                                       ; preds = %while.end
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %121, align 8, !tbaa !38
  br label %if.end234

if.else231:                                       ; preds = %while.end
  tail call void %5() #8
  unreachable

if.end234:                                        ; preds = %if.then230, %lor.lhs.false, %if.then199
  %R.3 = phi %struct.malloc_tree_chunk* [ %89, %if.then199 ], [ %R.1, %if.then230 ], [ null, %lor.lhs.false ]
  %132 = phi %struct.malloc_tree_chunk* [ %89, %if.then199 ], [ %R.1, %if.then230 ], [ %118, %lor.lhs.false ]
  %cmp235 = icmp eq %struct.malloc_tree_chunk* %86, null
  br i1 %cmp235, label %if.end324, label %if.then237

if.then237:                                       ; preds = %if.end234
  %133 = getelementptr inbounds i64, i64* %7, i64 75
  %134 = bitcast i64* %133 to [32 x %struct.malloc_tree_chunk*]*
  %135 = getelementptr inbounds i8, i8* %16, i64 56
  %136 = bitcast i8* %135 to i32*
  %137 = load i32, i32* %136, align 8, !tbaa !44
  %idxprom238 = zext i32 %137 to i64
  %138 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %134, i64 0, i64 %idxprom238
  %139 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %138, align 8, !tbaa !38
  %cmp240 = icmp eq %struct.malloc_tree_chunk* %139, %83
  br i1 %cmp240, label %if.then242, label %if.else251

if.then242:                                       ; preds = %if.then237
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %138, align 8, !tbaa !38
  %cond = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cond, label %if.end272.thread, label %if.then275

if.end272.thread:                                 ; preds = %if.then242
  %shl247 = shl i32 1, %137
  %neg248 = xor i32 %shl247, -1
  %140 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %8, i64 0, i32 1
  %141 = load i32, i32* %140, align 4, !tbaa !35
  %and249 = and i32 %141, %neg248
  store i32 %and249, i32* %140, align 4, !tbaa !35
  br label %if.end324

if.else251:                                       ; preds = %if.then237
  %142 = bitcast %struct.malloc_tree_chunk* %86 to i8*
  %143 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp253 = icmp ugt i8* %143, %142
  br i1 %cmp253, label %if.else270, label %if.end272, !prof !34

if.else270:                                       ; preds = %if.else251
  tail call void %5() #8
  unreachable

if.end272:                                        ; preds = %if.else251
  %144 = getelementptr inbounds i64, i64* %91, i64 4
  %145 = bitcast i64* %144 to [2 x %struct.malloc_tree_chunk*]*
  %146 = bitcast i64* %144 to %struct.malloc_tree_chunk**
  %147 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %146, align 8, !tbaa !38
  %cmp261 = icmp ne %struct.malloc_tree_chunk* %147, %83
  %.sink = zext i1 %cmp261 to i64
  %148 = getelementptr inbounds [2 x %struct.malloc_tree_chunk*], [2 x %struct.malloc_tree_chunk*]* %145, i64 0, i64 %.sink
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %148, align 8, !tbaa !38
  %cmp273 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cmp273, label %if.end324, label %if.then275

if.then275:                                       ; preds = %if.then242, %if.end272
  %149 = bitcast %struct.malloc_tree_chunk* %R.3 to i8*
  %150 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp277 = icmp ugt i8* %150, %149
  br i1 %cmp277, label %if.else320, label %if.then282, !prof !34

if.then282:                                       ; preds = %if.then275
  %151 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %132, i64 0, i32 5
  store %struct.malloc_tree_chunk* %86, %struct.malloc_tree_chunk** %151, align 8, !tbaa !41
  %152 = getelementptr inbounds i8, i8* %16, i64 32
  %153 = bitcast i8* %152 to %struct.malloc_tree_chunk**
  %154 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %153, align 8, !tbaa !38
  %cmp286 = icmp eq %struct.malloc_tree_chunk* %154, null
  %155 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %154, i64 0, i32 0
  %156 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %155) #7
  br i1 %cmp286, label %if.end301, label %if.then288

if.then288:                                       ; preds = %if.then282
  %157 = bitcast %struct.malloc_tree_chunk* %154 to i8*
  %158 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp290 = icmp ugt i8* %158, %157
  br i1 %cmp290, label %if.else299, label %if.then295, !prof !34

if.then295:                                       ; preds = %if.then288
  %159 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %132, i64 0, i32 4, i64 0
  store %struct.malloc_tree_chunk* %154, %struct.malloc_tree_chunk** %159, align 8, !tbaa !38
  %160 = getelementptr inbounds i64, i64* %156, i64 6
  %161 = bitcast i64* %160 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %161, align 8, !tbaa !41
  br label %if.end301

if.else299:                                       ; preds = %if.then288
  tail call void %5() #8
  unreachable

if.end301:                                        ; preds = %if.then282, %if.then295
  %162 = getelementptr inbounds i8, i8* %152, i64 8
  %163 = bitcast i8* %162 to %struct.malloc_tree_chunk**
  %164 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %163, align 8, !tbaa !38
  %cmp304 = icmp eq %struct.malloc_tree_chunk* %164, null
  %165 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %164, i64 0, i32 0
  %166 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %165) #7
  br i1 %cmp304, label %if.end324, label %if.then306

if.then306:                                       ; preds = %if.end301
  %167 = bitcast %struct.malloc_tree_chunk* %164 to i8*
  %168 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp308 = icmp ugt i8* %168, %167
  br i1 %cmp308, label %if.else317, label %if.then313, !prof !34

if.then313:                                       ; preds = %if.then306
  %169 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %132, i64 0, i32 4, i64 1
  store %struct.malloc_tree_chunk* %164, %struct.malloc_tree_chunk** %169, align 8, !tbaa !38
  %170 = getelementptr inbounds i64, i64* %166, i64 6
  %171 = bitcast i64* %170 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %171, align 8, !tbaa !41
  br label %if.end324

if.else317:                                       ; preds = %if.then306
  tail call void %5() #8
  unreachable

if.else320:                                       ; preds = %if.then275
  tail call void %5() #8
  unreachable

if.end324:                                        ; preds = %if.end272.thread, %if.end234, %if.then313, %if.end301, %if.end272, %if.then167, %if.then142
  %cmp325 = icmp ult i64 %sub119, 32
  br i1 %cmp325, label %if.then327, label %if.else338

if.then327:                                       ; preds = %if.end324
  %172 = load i64, i64* %12, align 8, !tbaa !11
  %and331 = and i64 %172, 1
  %or332 = or i64 %add113, %and331
  %or333 = or i64 %or332, 2
  store i64 %or333, i64* %12, align 8, !tbaa !11
  %173 = getelementptr inbounds i8, i8* %15, i64 %add113
  %174 = getelementptr inbounds i8, i8* %173, i64 8
  %175 = bitcast i8* %174 to i64*
  %176 = load i64, i64* %175, align 8, !tbaa !11
  %or337 = or i64 %176, 1
  store i64 %or337, i64* %175, align 8, !tbaa !11
  br label %if.end365

if.else338:                                       ; preds = %if.end324
  %add.ptr340 = getelementptr inbounds i8, i8* %14, i64 %nb
  %177 = getelementptr inbounds i8, i8* %15, i64 %nb
  %178 = bitcast i8* %add.ptr340 to %struct.malloc_chunk*
  %179 = load i64, i64* %12, align 8, !tbaa !11
  %and342 = and i64 %179, 1
  %or343 = or i64 %and342, %nb
  %or344 = or i64 %or343, 2
  store i64 %or344, i64* %12, align 8, !tbaa !11
  %180 = getelementptr inbounds i8, i8* %177, i64 8
  %181 = bitcast i8* %180 to i64*
  %or352 = or i64 %sub119, 3
  store i64 %or352, i64* %181, align 8, !tbaa !11
  %182 = getelementptr inbounds i8, i8* %15, i64 %add113
  %183 = getelementptr inbounds i8, i8* %182, i64 8
  %184 = bitcast i8* %183 to i64*
  %185 = load i64, i64* %184, align 8, !tbaa !11
  %or356 = or i64 %185, 1
  store i64 %or356, i64* %184, align 8, !tbaa !11
  tail call void %3(%struct.malloc_state* %m, %struct.malloc_chunk* %178, i64 %sub119) #7
  br label %if.end365

if.else364:                                       ; preds = %land.rhs, %entry
  tail call void %5() #8
  unreachable

if.end365:                                        ; preds = %if.then110, %if.else338, %if.then327, %if.end104, %if.then63, %if.then16, %if.then19, %if.else106, %if.then13, %if.then42, %if.then39
  %newp.2 = phi %struct.malloc_chunk* [ %call, %if.then13 ], [ %p, %if.then42 ], [ null, %if.then39 ], [ null, %if.else106 ], [ %p, %if.then19 ], [ %p, %if.then16 ], [ %p, %if.end104 ], [ null, %if.then63 ], [ null, %if.then110 ], [ %p, %if.else338 ], [ %p, %if.then327 ]
  ret %struct.malloc_chunk* %newp.2
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #2

; Function Attrs: nounwind uwtable
define i8* @mspace_realloc_in_place(i8* %msp, i8* %oldmem, i64 %bytes) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (%struct.malloc_chunk* (%struct.malloc_state*, %struct.malloc_chunk*, i64, i32)* @try_realloc_chunk to i64*)) #7
  %1 = bitcast i64* %0 to %struct.malloc_chunk* (%struct.malloc_state*, %struct.malloc_chunk*, i64, i32)*
  %2 = bitcast i8* %oldmem to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32* ()* @__errno_location to i64*)) #7
  %5 = bitcast i64* %4 to i32* ()*
  %6 = bitcast i8* %msp to i64*
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %6) #7
  %8 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %cmp = icmp eq i8* %oldmem, null
  br i1 %cmp, label %if.end9, label %if.then

if.then:                                          ; preds = %entry
  %cmp1 = icmp ugt i64 %bytes, -129
  br i1 %cmp1, label %if.then2, label %if.else

if.then2:                                         ; preds = %if.then
  %call = tail call i32* %5() #4
  %9 = bitcast i32* %call to i64*
  %10 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %9) #7
  %11 = bitcast i64* %10 to i32*
  store i32 12, i32* %11, align 4, !tbaa !23
  br label %if.end9

if.else:                                          ; preds = %if.then
  %cmp3 = icmp ult i64 %bytes, 23
  %add4 = add i64 %bytes, 23
  %and = and i64 %add4, -16
  %cond = select i1 %cmp3, i64 32, i64 %and
  %add.ptr = getelementptr inbounds i8, i8* %oldmem, i64 -16
  %12 = bitcast i8* %add.ptr to %struct.malloc_chunk*
  %13 = bitcast i8* %msp to %struct.malloc_state*
  %call5 = tail call %struct.malloc_chunk* %1(%struct.malloc_state* %13, %struct.malloc_chunk* %12, i64 %cond, i32 0) #7
  %cmp6 = icmp eq %struct.malloc_chunk* %call5, %12
  %oldmem. = select i1 %cmp6, i8* %oldmem, i8* null
  br label %if.end9

if.end9:                                          ; preds = %entry, %if.then2, %if.else
  %mem.1 = phi i8* [ null, %if.then2 ], [ %oldmem., %if.else ], [ null, %entry ]
  ret i8* %mem.1
}

; Function Attrs: nounwind uwtable
define i8* @mspace_memalign(i8* %msp, i64 %alignment, i64 %bytes) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64)* @mspace_malloc to i64*)) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (%struct.malloc_state*, i64, i64)* @internal_memalign to i64*)) #7
  %2 = bitcast i8* %msp to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %cmp = icmp ult i64 %alignment, 17
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %4 = bitcast i64* %0 to i8* (i8*, i64)*
  %call = tail call i8* %4(i8* %msp, i64 %bytes) #7
  %5 = bitcast i8* %call to i64*
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %5) #7
  br label %cleanup

if.end:                                           ; preds = %entry
  %7 = bitcast i8* %msp to %struct.malloc_state*
  %8 = bitcast i64* %1 to i8* (%struct.malloc_state*, i64, i64)*
  %call1 = tail call i8* %8(%struct.malloc_state* %7, i64 %alignment, i64 %bytes) #7
  %9 = bitcast i8* %call1 to i64*
  %10 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %9) #7
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  %retval.0 = phi i8* [ %call, %if.then ], [ %call1, %if.end ]
  ret i8* %retval.0
}

; Function Attrs: nounwind uwtable
define internal i8* @internal_memalign(%struct.malloc_state* %m, i64 %alignment, i64 %bytes) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32* ()* @__errno_location to i64*)) #7
  %2 = bitcast i64* %1 to i32* ()*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64)* @mspace_malloc to i64*)) #7
  %4 = bitcast i64* %3 to i8* (i8*, i64)*
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*, %struct.malloc_chunk*, i64)* @dispose_chunk to i64*)) #7
  %6 = bitcast i64* %5 to void (%struct.malloc_state*, %struct.malloc_chunk*, i64)*
  %7 = bitcast %struct.malloc_state* %m to i64*
  %8 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %7) #7
  %9 = icmp ugt i64 %alignment, 32
  %.alignment = select i1 %9, i64 %alignment, i64 32
  %sub = add i64 %.alignment, -1
  %and = and i64 %sub, %.alignment
  %cmp1 = icmp eq i64 %and, 0
  br i1 %cmp1, label %if.end4, label %while.cond

while.cond:                                       ; preds = %entry, %while.cond
  %a.0 = phi i64 [ %shl, %while.cond ], [ 32, %entry ]
  %cmp3 = icmp ult i64 %a.0, %.alignment
  %shl = shl i64 %a.0, 1
  br i1 %cmp3, label %while.cond, label %if.end4

if.end4:                                          ; preds = %while.cond, %entry
  %alignment.addr.1 = phi i64 [ %.alignment, %entry ], [ %a.0, %while.cond ]
  %sub5 = sub i64 -128, %alignment.addr.1
  %cmp6 = icmp ugt i64 %sub5, %bytes
  br i1 %cmp6, label %if.else, label %if.then7

if.then7:                                         ; preds = %if.end4
  %cmp8 = icmp eq %struct.malloc_state* %m, null
  br i1 %cmp8, label %if.end96, label %if.then9

if.then9:                                         ; preds = %if.then7
  %call = tail call i32* %2() #4
  %10 = bitcast i32* %call to i64*
  %11 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %10) #7
  %12 = bitcast i64* %11 to i32*
  store i32 12, i32* %12, align 4, !tbaa !23
  br label %if.end96

if.else:                                          ; preds = %if.end4
  %cmp11 = icmp ult i64 %bytes, 23
  %add12 = add i64 %bytes, 23
  %and13 = and i64 %add12, -16
  %cond = select i1 %cmp11, i64 32, i64 %and13
  %add14 = add i64 %cond, 24
  %sub16 = add i64 %add14, %alignment.addr.1
  %13 = bitcast %struct.malloc_state* %m to i8*
  %call17 = tail call i8* %4(i8* %13, i64 %sub16) #7
  %cmp18 = icmp eq i8* %call17, null
  %14 = bitcast i8* %call17 to i64*
  %15 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %14) #7
  br i1 %cmp18, label %if.end96, label %if.then19

if.then19:                                        ; preds = %if.else
  %add.ptr = getelementptr inbounds i8, i8* %call17, i64 -16
  %16 = getelementptr inbounds i64, i64* %15, i64 -2
  %17 = bitcast i8* %add.ptr to %struct.malloc_chunk*
  %18 = bitcast i64* %16 to %struct.malloc_chunk*
  %19 = ptrtoint i8* %call17 to i64
  %sub20 = add i64 %alignment.addr.1, -1
  %and21 = and i64 %sub20, %19
  %cmp22 = icmp eq i64 %and21, 0
  br i1 %cmp22, label %if.end64, label %if.then23

if.then23:                                        ; preds = %if.then19
  %add.ptr24 = getelementptr inbounds i8, i8* %call17, i64 %alignment.addr.1
  %add.ptr25 = getelementptr inbounds i8, i8* %add.ptr24, i64 -1
  %20 = ptrtoint i8* %add.ptr25 to i64
  %sub26 = sub i64 0, %alignment.addr.1
  %and27 = and i64 %20, %sub26
  %21 = inttoptr i64 %and27 to i64*
  %22 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %21) #7
  %23 = inttoptr i64 %and27 to i8*
  %add.ptr28 = getelementptr inbounds i8, i8* %23, i64 -16
  %24 = getelementptr inbounds i64, i64* %22, i64 -2
  %25 = bitcast i64* %24 to i8*
  %sub.ptr.lhs.cast = ptrtoint i8* %add.ptr28 to i64
  %sub.ptr.rhs.cast = ptrtoint i8* %add.ptr to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %cmp29 = icmp ugt i64 %sub.ptr.sub, 31
  %add.ptr32 = getelementptr inbounds i8, i8* %add.ptr28, i64 %alignment.addr.1
  %26 = getelementptr inbounds i8, i8* %25, i64 %alignment.addr.1
  %27 = select i1 %cmp29, i8* %25, i8* %26
  %cond34 = select i1 %cmp29, i8* %add.ptr28, i8* %add.ptr32
  %28 = bitcast i8* %cond34 to %struct.malloc_chunk*
  %sub.ptr.lhs.cast35 = ptrtoint i8* %cond34 to i64
  %sub.ptr.sub37 = sub i64 %sub.ptr.lhs.cast35, %sub.ptr.rhs.cast
  %29 = getelementptr inbounds i64, i64* %15, i64 -1
  %30 = load i64, i64* %29, align 8, !tbaa !11
  %and38 = and i64 %30, -8
  %sub39 = sub i64 %and38, %sub.ptr.sub37
  %and41 = and i64 %30, 3
  %cmp42 = icmp eq i64 %and41, 0
  br i1 %cmp42, label %if.then43, label %if.else47

if.then43:                                        ; preds = %if.then23
  %31 = load i64, i64* %16, align 8, !tbaa !32
  %add44 = add i64 %31, %sub.ptr.sub37
  %32 = bitcast i8* %27 to i64*
  store i64 %add44, i64* %32, align 8, !tbaa !32
  %33 = getelementptr inbounds i8, i8* %27, i64 8
  %34 = bitcast i8* %33 to i64*
  store i64 %sub39, i64* %34, align 8, !tbaa !11
  br label %if.end64

if.else47:                                        ; preds = %if.then23
  %35 = getelementptr inbounds i8, i8* %27, i64 8
  %36 = bitcast i8* %35 to i64*
  %37 = load i64, i64* %36, align 8, !tbaa !11
  %and49 = and i64 %37, 1
  %or = or i64 %sub39, %and49
  %or50 = or i64 %or, 2
  store i64 %or50, i64* %36, align 8, !tbaa !11
  %38 = getelementptr inbounds i8, i8* %27, i64 %sub39
  %39 = getelementptr inbounds i8, i8* %38, i64 8
  %40 = bitcast i8* %39 to i64*
  %41 = load i64, i64* %40, align 8, !tbaa !11
  %or54 = or i64 %41, 1
  store i64 %or54, i64* %40, align 8, !tbaa !11
  %42 = load i64, i64* %29, align 8, !tbaa !11
  %and56 = and i64 %42, 1
  %or57 = or i64 %sub.ptr.sub37, %and56
  %or58 = or i64 %or57, 2
  store i64 %or58, i64* %29, align 8, !tbaa !11
  %43 = load i64, i64* %36, align 8, !tbaa !11
  %or62 = or i64 %43, 1
  store i64 %or62, i64* %36, align 8, !tbaa !11
  tail call void %6(%struct.malloc_state* %m, %struct.malloc_chunk* %17, i64 %sub.ptr.sub37) #7
  br label %if.end64

if.end64:                                         ; preds = %if.then43, %if.else47, %if.then19
  %44 = phi i8* [ %add.ptr, %if.then19 ], [ %cond34, %if.else47 ], [ %cond34, %if.then43 ]
  %45 = phi %struct.malloc_chunk* [ %18, %if.then19 ], [ %28, %if.else47 ], [ %28, %if.then43 ]
  %46 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %45, i64 0, i32 1
  %47 = load i64, i64* %46, align 8, !tbaa !11
  %and66 = and i64 %47, 3
  %cmp67 = icmp eq i64 %and66, 0
  br i1 %cmp67, label %if.end93, label %if.then68

if.then68:                                        ; preds = %if.end64
  %and70 = and i64 %47, -8
  %add71 = add i64 %cond, 32
  %cmp72 = icmp ugt i64 %and70, %add71
  br i1 %cmp72, label %if.then73, label %if.end93

if.then73:                                        ; preds = %if.then68
  %sub74 = sub i64 %and70, %cond
  %48 = bitcast %struct.malloc_chunk* %45 to i8*
  %add.ptr75 = getelementptr inbounds i8, i8* %44, i64 %cond
  %49 = getelementptr inbounds i8, i8* %48, i64 %cond
  %50 = bitcast i8* %add.ptr75 to %struct.malloc_chunk*
  %and77 = and i64 %47, 1
  %or78 = or i64 %cond, %and77
  %or79 = or i64 %or78, 2
  store i64 %or79, i64* %46, align 8, !tbaa !11
  %51 = getelementptr inbounds i8, i8* %49, i64 8
  %52 = bitcast i8* %51 to i64*
  %or87 = or i64 %sub74, 3
  store i64 %or87, i64* %52, align 8, !tbaa !11
  %53 = getelementptr inbounds i8, i8* %48, i64 %and70
  %54 = getelementptr inbounds i8, i8* %53, i64 8
  %55 = bitcast i8* %54 to i64*
  %56 = load i64, i64* %55, align 8, !tbaa !11
  %or91 = or i64 %56, 1
  store i64 %or91, i64* %55, align 8, !tbaa !11
  tail call void %6(%struct.malloc_state* %m, %struct.malloc_chunk* %50, i64 %sub74) #7
  br label %if.end93

if.end93:                                         ; preds = %if.then68, %if.then73, %if.end64
  %add.ptr94 = getelementptr inbounds i8, i8* %44, i64 16
  br label %if.end96

if.end96:                                         ; preds = %if.end93, %if.else, %if.then7, %if.then9
  %mem.1 = phi i8* [ null, %if.then9 ], [ null, %if.then7 ], [ %add.ptr94, %if.end93 ], [ null, %if.else ]
  ret i8* %mem.1
}

; Function Attrs: nounwind uwtable
define i8** @mspace_independent_calloc(i8* %msp, i64 %n_elements, i64 %elem_size, i8** %chunks) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** (%struct.malloc_state*, i64, i64*, i32, i8**)* @ialloc to i64*)) #7
  %1 = bitcast i64* %0 to i8** (%struct.malloc_state*, i64, i64*, i32, i8**)*
  %2 = bitcast i8* %msp to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %sz = alloca i64, align 8
  %4 = bitcast i64* %sz to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %4) #7
  store i64 %elem_size, i64* %sz, align 8, !tbaa !8
  %5 = bitcast i8* %msp to %struct.malloc_state*
  %6 = tail call i64* asm "mov $1,$0;sub %rsp,$0;add %r13,$0;", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* nonnull %sz) #7
  %call = call i8** %1(%struct.malloc_state* %5, i64 %n_elements, i64* %6, i32 3, i8** %chunks) #7
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %4) #7
  ret i8** %call
}

; Function Attrs: nounwind uwtable
define internal i8** @ialloc(%struct.malloc_state* %m, i64 %n_elements, i64* %sizes, i32 %opts, i8** %chunks) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %1 = bitcast i64* %0 to i8**
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %sizes) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64)* @mspace_malloc to i64*)) #7
  %4 = bitcast i64* %3 to i8* (i8*, i64)*
  %5 = bitcast %struct.malloc_state* %m to i64*
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %5) #7
  %7 = bitcast i8** %chunks to i64*
  %8 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %7) #7
  %9 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 ()* @init_mparams to i64*)) #7
  %10 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %11 = load i64, i64* %10, align 8, !tbaa !1
  %cmp = icmp eq i64 %11, 0
  br i1 %cmp, label %lor.rhs, label %lor.end

lor.rhs:                                          ; preds = %entry
  %12 = bitcast i64* %9 to i32 ()*
  %call = tail call i32 %12() #7
  br label %lor.end

lor.end:                                          ; preds = %entry, %lor.rhs
  %cmp1 = icmp eq i8** %chunks, null
  %cmp2 = icmp eq i64 %n_elements, 0
  br i1 %cmp1, label %if.else, label %if.then

if.then:                                          ; preds = %lor.end
  br i1 %cmp2, label %cleanup, label %if.end11

if.else:                                          ; preds = %lor.end
  br i1 %cmp2, label %if.then5, label %if.end7

if.then5:                                         ; preds = %if.else
  %13 = bitcast %struct.malloc_state* %m to i8*
  %call6 = tail call i8* %4(i8* %13, i64 0) #7
  %14 = bitcast i8* %call6 to i64*
  %15 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %14) #7
  %16 = bitcast i8* %call6 to i8**
  br label %cleanup

if.end7:                                          ; preds = %if.else
  %mul = shl i64 %n_elements, 3
  %cmp8 = icmp ult i64 %mul, 23
  %add10 = add i64 %mul, 23
  %and = and i64 %add10, -16
  %cond = select i1 %cmp8, i64 32, i64 %and
  br label %if.end11

if.end11:                                         ; preds = %if.end7, %if.then
  %array_size.0 = phi i64 [ 0, %if.then ], [ %cond, %if.end7 ]
  %marray.0 = phi i8** [ %chunks, %if.then ], [ null, %if.end7 ]
  %17 = phi i8** [ %chunks, %if.then ], [ %1, %if.end7 ]
  %and12 = and i32 %opts, 1
  %tobool13 = icmp eq i32 %and12, 0
  br i1 %tobool13, label %for.body.preheader, label %if.then14

for.body.preheader:                               ; preds = %if.end11
  %min.iters.check = icmp ult i64 %n_elements, 4
  br i1 %min.iters.check, label %for.body, label %min.iters.checked

min.iters.checked:                                ; preds = %for.body.preheader
  %n.vec = and i64 %n_elements, -4
  %cmp.zero = icmp eq i64 %n.vec, 0
  br i1 %cmp.zero, label %for.body, label %vector.body.preheader

vector.body.preheader:                            ; preds = %min.iters.checked
  %18 = add i64 %n.vec, -4
  %19 = lshr exact i64 %18, 2
  %20 = add nuw nsw i64 %19, 1
  %xtraiter192 = and i64 %20, 1
  %21 = icmp eq i64 %19, 0
  br i1 %21, label %middle.block.unr-lcssa, label %vector.body.preheader.new

vector.body.preheader.new:                        ; preds = %vector.body.preheader
  %unroll_iter194 = sub nsw i64 %20, %xtraiter192
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.body.preheader.new
  %index = phi i64 [ 0, %vector.body.preheader.new ], [ %index.next.1, %vector.body ]
  %vec.phi = phi <2 x i64> [ zeroinitializer, %vector.body.preheader.new ], [ %48, %vector.body ]
  %vec.phi184 = phi <2 x i64> [ zeroinitializer, %vector.body.preheader.new ], [ %49, %vector.body ]
  %niter195 = phi i64 [ %unroll_iter194, %vector.body.preheader.new ], [ %niter195.nsub.1, %vector.body ]
  %22 = getelementptr inbounds i64, i64* %2, i64 %index
  %23 = bitcast i64* %22 to <2 x i64>*
  %wide.load = load <2 x i64>, <2 x i64>* %23, align 8, !tbaa !8
  %24 = getelementptr i64, i64* %22, i64 2
  %25 = bitcast i64* %24 to <2 x i64>*
  %wide.load185 = load <2 x i64>, <2 x i64>* %25, align 8, !tbaa !8
  %26 = icmp ult <2 x i64> %wide.load, <i64 23, i64 23>
  %27 = icmp ult <2 x i64> %wide.load185, <i64 23, i64 23>
  %28 = add <2 x i64> %wide.load, <i64 23, i64 23>
  %29 = add <2 x i64> %wide.load185, <i64 23, i64 23>
  %30 = and <2 x i64> %28, <i64 -16, i64 -16>
  %31 = and <2 x i64> %29, <i64 -16, i64 -16>
  %32 = select <2 x i1> %26, <2 x i64> <i64 32, i64 32>, <2 x i64> %30
  %33 = select <2 x i1> %27, <2 x i64> <i64 32, i64 32>, <2 x i64> %31
  %34 = add <2 x i64> %32, %vec.phi
  %35 = add <2 x i64> %33, %vec.phi184
  %index.next = or i64 %index, 4
  %36 = getelementptr inbounds i64, i64* %2, i64 %index.next
  %37 = bitcast i64* %36 to <2 x i64>*
  %wide.load.1 = load <2 x i64>, <2 x i64>* %37, align 8, !tbaa !8
  %38 = getelementptr i64, i64* %36, i64 2
  %39 = bitcast i64* %38 to <2 x i64>*
  %wide.load185.1 = load <2 x i64>, <2 x i64>* %39, align 8, !tbaa !8
  %40 = icmp ult <2 x i64> %wide.load.1, <i64 23, i64 23>
  %41 = icmp ult <2 x i64> %wide.load185.1, <i64 23, i64 23>
  %42 = add <2 x i64> %wide.load.1, <i64 23, i64 23>
  %43 = add <2 x i64> %wide.load185.1, <i64 23, i64 23>
  %44 = and <2 x i64> %42, <i64 -16, i64 -16>
  %45 = and <2 x i64> %43, <i64 -16, i64 -16>
  %46 = select <2 x i1> %40, <2 x i64> <i64 32, i64 32>, <2 x i64> %44
  %47 = select <2 x i1> %41, <2 x i64> <i64 32, i64 32>, <2 x i64> %45
  %48 = add <2 x i64> %46, %34
  %49 = add <2 x i64> %47, %35
  %index.next.1 = add i64 %index, 8
  %niter195.nsub.1 = add i64 %niter195, -2
  %niter195.ncmp.1 = icmp eq i64 %niter195.nsub.1, 0
  br i1 %niter195.ncmp.1, label %middle.block.unr-lcssa, label %vector.body, !llvm.loop !49

middle.block.unr-lcssa:                           ; preds = %vector.body, %vector.body.preheader
  %.lcssa190.ph = phi <2 x i64> [ undef, %vector.body.preheader ], [ %48, %vector.body ]
  %.lcssa189.ph = phi <2 x i64> [ undef, %vector.body.preheader ], [ %49, %vector.body ]
  %index.unr = phi i64 [ 0, %vector.body.preheader ], [ %index.next.1, %vector.body ]
  %vec.phi.unr = phi <2 x i64> [ zeroinitializer, %vector.body.preheader ], [ %48, %vector.body ]
  %vec.phi184.unr = phi <2 x i64> [ zeroinitializer, %vector.body.preheader ], [ %49, %vector.body ]
  %lcmp.mod193 = icmp eq i64 %xtraiter192, 0
  br i1 %lcmp.mod193, label %middle.block, label %vector.body.epil

vector.body.epil:                                 ; preds = %middle.block.unr-lcssa
  %50 = getelementptr inbounds i64, i64* %2, i64 %index.unr
  %51 = bitcast i64* %50 to <2 x i64>*
  %wide.load.epil = load <2 x i64>, <2 x i64>* %51, align 8, !tbaa !8
  %52 = getelementptr i64, i64* %50, i64 2
  %53 = bitcast i64* %52 to <2 x i64>*
  %wide.load185.epil = load <2 x i64>, <2 x i64>* %53, align 8, !tbaa !8
  %54 = icmp ult <2 x i64> %wide.load185.epil, <i64 23, i64 23>
  %55 = add <2 x i64> %wide.load185.epil, <i64 23, i64 23>
  %56 = and <2 x i64> %55, <i64 -16, i64 -16>
  %57 = select <2 x i1> %54, <2 x i64> <i64 32, i64 32>, <2 x i64> %56
  %58 = add <2 x i64> %57, %vec.phi184.unr
  %59 = icmp ult <2 x i64> %wide.load.epil, <i64 23, i64 23>
  %60 = add <2 x i64> %wide.load.epil, <i64 23, i64 23>
  %61 = and <2 x i64> %60, <i64 -16, i64 -16>
  %62 = select <2 x i1> %59, <2 x i64> <i64 32, i64 32>, <2 x i64> %61
  %63 = add <2 x i64> %62, %vec.phi.unr
  br label %middle.block

middle.block:                                     ; preds = %middle.block.unr-lcssa, %vector.body.epil
  %.lcssa190 = phi <2 x i64> [ %.lcssa190.ph, %middle.block.unr-lcssa ], [ %63, %vector.body.epil ]
  %.lcssa189 = phi <2 x i64> [ %.lcssa189.ph, %middle.block.unr-lcssa ], [ %58, %vector.body.epil ]
  %bin.rdx = add <2 x i64> %.lcssa189, %.lcssa190
  %rdx.shuf = shufflevector <2 x i64> %bin.rdx, <2 x i64> undef, <2 x i32> <i32 1, i32 undef>
  %bin.rdx186 = add <2 x i64> %bin.rdx, %rdx.shuf
  %64 = extractelement <2 x i64> %bin.rdx186, i32 0
  %cmp.n = icmp eq i64 %n.vec, %n_elements
  br i1 %cmp.n, label %if.end36, label %for.body

if.then14:                                        ; preds = %if.end11
  %65 = load i64, i64* %2, align 8, !tbaa !8
  %cmp15 = icmp ult i64 %65, 23
  %add19 = add i64 %65, 23
  %and20 = and i64 %add19, -16
  %cond22 = select i1 %cmp15, i64 32, i64 %and20
  %mul23 = mul i64 %cond22, %n_elements
  br label %if.end36

for.body:                                         ; preds = %for.body.preheader, %min.iters.checked, %middle.block, %for.body
  %i.0178 = phi i64 [ %inc, %for.body ], [ 0, %min.iters.checked ], [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  %contents_size.0177 = phi i64 [ %add35, %for.body ], [ 0, %min.iters.checked ], [ 0, %for.body.preheader ], [ %64, %middle.block ]
  %66 = getelementptr inbounds i64, i64* %2, i64 %i.0178
  %67 = load i64, i64* %66, align 8, !tbaa !8
  %cmp26 = icmp ult i64 %67, 23
  %add31 = add i64 %67, 23
  %and32 = and i64 %add31, -16
  %cond34 = select i1 %cmp26, i64 32, i64 %and32
  %add35 = add i64 %cond34, %contents_size.0177
  %inc = add nuw i64 %i.0178, 1
  %cmp25 = icmp eq i64 %inc, %n_elements
  br i1 %cmp25, label %if.end36, label %for.body, !llvm.loop !52

if.end36:                                         ; preds = %for.body, %middle.block, %if.then14
  %contents_size.1 = phi i64 [ %mul23, %if.then14 ], [ %64, %middle.block ], [ %add35, %for.body ]
  %element_size.0 = phi i64 [ %cond22, %if.then14 ], [ 0, %middle.block ], [ 0, %for.body ]
  %68 = bitcast %struct.malloc_state* %m to i8*
  %add37 = add i64 %array_size.0, -8
  %sub = add i64 %add37, %contents_size.1
  %call40 = tail call i8* %4(i8* %68, i64 %sub) #7
  %69 = bitcast i8* %call40 to i64*
  %70 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %69) #7
  %71 = bitcast i64* %70 to i8*
  %cmp47 = icmp eq i8* %call40, null
  br i1 %cmp47, label %cleanup, label %if.end50

if.end50:                                         ; preds = %if.end36
  %add.ptr = getelementptr inbounds i8, i8* %call40, i64 -16
  %72 = getelementptr inbounds i64, i64* %70, i64 -2
  %73 = bitcast i64* %72 to i8*
  %74 = bitcast i64* %72 to %struct.malloc_chunk*
  %75 = getelementptr inbounds i64, i64* %70, i64 -1
  %76 = load i64, i64* %75, align 8, !tbaa !11
  %and51 = and i64 %76, -8
  %and52 = and i32 %opts, 2
  %tobool53 = icmp eq i32 %and52, 0
  br i1 %tobool53, label %if.end57, label %if.then54

if.then54:                                        ; preds = %if.end50
  %sub55 = sub i64 -8, %array_size.0
  %sub56 = add i64 %sub55, %and51
  tail call void @llvm.memset.p0i8.i64(i8* nonnull %71, i8 0, i64 %sub56, i32 8, i1 false)
  br label %if.end57

if.end57:                                         ; preds = %if.end50, %if.then54
  %cmp58 = icmp eq i8** %marray.0, null
  br i1 %cmp58, label %if.then60, label %if.end66

if.then60:                                        ; preds = %if.end57
  %add.ptr61 = getelementptr inbounds i8, i8* %add.ptr, i64 %contents_size.1
  %77 = getelementptr inbounds i8, i8* %73, i64 %contents_size.1
  %sub62 = sub i64 %and51, %contents_size.1
  %add.ptr63 = getelementptr inbounds i8, i8* %add.ptr61, i64 16
  %78 = bitcast i8* %add.ptr63 to i8**
  %or64 = or i64 %sub62, 3
  %79 = getelementptr inbounds i8, i8* %77, i64 8
  %80 = bitcast i8* %79 to i64*
  store i64 %or64, i64* %80, align 8, !tbaa !11
  br label %if.end66

if.end66:                                         ; preds = %if.then60, %if.end57
  %remainder_size.0 = phi i64 [ %contents_size.1, %if.then60 ], [ %and51, %if.end57 ]
  %marray.1 = phi i8** [ %78, %if.then60 ], [ %marray.0, %if.end57 ]
  %81 = phi i8** [ %78, %if.then60 ], [ %17, %if.end57 ]
  store i8* %call40, i8** %81, align 8, !tbaa !38
  %sub70 = add i64 %n_elements, -1
  %cmp71172 = icmp eq i64 %sub70, 0
  br i1 %cmp71172, label %if.else95, label %if.then73.lr.ph

if.then73.lr.ph:                                  ; preds = %if.end66
  %cmp74 = icmp eq i64 %element_size.0, 0
  %xtraiter = and i64 %sub70, 1
  %82 = icmp eq i64 %n_elements, 2
  br i1 %82, label %if.else95.loopexit.unr-lcssa, label %if.then73.lr.ph.new

if.then73.lr.ph.new:                              ; preds = %if.then73.lr.ph
  %unroll_iter = sub i64 %sub70, %xtraiter
  br label %if.then73

if.then73:                                        ; preds = %if.end89.1, %if.then73.lr.ph.new
  %i.1174 = phi i64 [ 0, %if.then73.lr.ph.new ], [ %inc101.1, %if.end89.1 ]
  %remainder_size.1173 = phi i64 [ %remainder_size.0, %if.then73.lr.ph.new ], [ %sub90.1, %if.end89.1 ]
  %83 = phi %struct.malloc_chunk* [ %74, %if.then73.lr.ph.new ], [ %99, %if.end89.1 ]
  %84 = phi i8* [ %add.ptr, %if.then73.lr.ph.new ], [ %add.ptr94.1, %if.end89.1 ]
  %niter = phi i64 [ %unroll_iter, %if.then73.lr.ph.new ], [ %niter.nsub.1, %if.end89.1 ]
  br i1 %cmp74, label %if.else77, label %if.end89

if.else77:                                        ; preds = %if.then73
  %85 = getelementptr inbounds i64, i64* %2, i64 %i.1174
  %86 = load i64, i64* %85, align 8, !tbaa !8
  %cmp79 = icmp ult i64 %86, 23
  %add85 = add i64 %86, 23
  %and86 = and i64 %add85, -16
  %cond88 = select i1 %cmp79, i64 32, i64 %and86
  br label %if.end89

if.end89:                                         ; preds = %if.else77, %if.then73
  %size.0 = phi i64 [ %element_size.0, %if.then73 ], [ %cond88, %if.else77 ]
  %sub90 = sub i64 %remainder_size.1173, %size.0
  %or92 = or i64 %size.0, 3
  %87 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %83, i64 0, i32 1
  store i64 %or92, i64* %87, align 8, !tbaa !11
  %add.ptr94 = getelementptr inbounds i8, i8* %84, i64 %size.0
  %inc101 = or i64 %i.1174, 1
  %add.ptr68 = getelementptr inbounds i8, i8* %add.ptr94, i64 16
  %88 = getelementptr inbounds i8*, i8** %81, i64 %inc101
  store i8* %add.ptr68, i8** %88, align 8, !tbaa !38
  br i1 %cmp74, label %if.else77.1, label %if.end89.1

if.else95.loopexit.unr-lcssa:                     ; preds = %if.end89.1, %if.then73.lr.ph
  %sub90.lcssa.ph = phi i64 [ undef, %if.then73.lr.ph ], [ %sub90.1, %if.end89.1 ]
  %.lcssa188.ph = phi %struct.malloc_chunk* [ undef, %if.then73.lr.ph ], [ %99, %if.end89.1 ]
  %i.1174.unr = phi i64 [ 0, %if.then73.lr.ph ], [ %inc101.1, %if.end89.1 ]
  %remainder_size.1173.unr = phi i64 [ %remainder_size.0, %if.then73.lr.ph ], [ %sub90.1, %if.end89.1 ]
  %.unr = phi %struct.malloc_chunk* [ %74, %if.then73.lr.ph ], [ %99, %if.end89.1 ]
  %.unr191 = phi i8* [ %add.ptr, %if.then73.lr.ph ], [ %add.ptr94.1, %if.end89.1 ]
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %if.else95, label %if.then73.epil

if.then73.epil:                                   ; preds = %if.else95.loopexit.unr-lcssa
  br i1 %cmp74, label %if.else77.epil, label %if.end89.epil

if.else77.epil:                                   ; preds = %if.then73.epil
  %89 = getelementptr inbounds i64, i64* %2, i64 %i.1174.unr
  %90 = load i64, i64* %89, align 8, !tbaa !8
  %cmp79.epil = icmp ult i64 %90, 23
  %add85.epil = add i64 %90, 23
  %and86.epil = and i64 %add85.epil, -16
  %cond88.epil = select i1 %cmp79.epil, i64 32, i64 %and86.epil
  br label %if.end89.epil

if.end89.epil:                                    ; preds = %if.else77.epil, %if.then73.epil
  %size.0.epil = phi i64 [ %element_size.0, %if.then73.epil ], [ %cond88.epil, %if.else77.epil ]
  %or92.epil = or i64 %size.0.epil, 3
  %91 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %.unr, i64 0, i32 1
  store i64 %or92.epil, i64* %91, align 8, !tbaa !11
  %add.ptr94.epil = getelementptr inbounds i8, i8* %.unr191, i64 %size.0.epil
  %inc101.epil = add nuw i64 %i.1174.unr, 1
  %add.ptr68.epil = getelementptr inbounds i8, i8* %add.ptr94.epil, i64 16
  %92 = getelementptr inbounds i8*, i8** %81, i64 %inc101.epil
  store i8* %add.ptr68.epil, i8** %92, align 8, !tbaa !38
  %93 = bitcast i8* %add.ptr94.epil to %struct.malloc_chunk*
  %sub90.epil = sub i64 %remainder_size.1173.unr, %size.0.epil
  br label %if.else95

if.else95:                                        ; preds = %if.end89.epil, %if.else95.loopexit.unr-lcssa, %if.end66
  %.lcssa = phi %struct.malloc_chunk* [ %74, %if.end66 ], [ %.lcssa188.ph, %if.else95.loopexit.unr-lcssa ], [ %93, %if.end89.epil ]
  %remainder_size.1.lcssa = phi i64 [ %remainder_size.0, %if.end66 ], [ %sub90.lcssa.ph, %if.else95.loopexit.unr-lcssa ], [ %sub90.epil, %if.end89.epil ]
  %or97 = or i64 %remainder_size.1.lcssa, 3
  %94 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %.lcssa, i64 0, i32 1
  store i64 %or97, i64* %94, align 8, !tbaa !11
  br label %cleanup

cleanup:                                          ; preds = %if.end36, %if.then, %if.else95, %if.then5
  %retval.0 = phi i8** [ %marray.1, %if.else95 ], [ %16, %if.then5 ], [ %chunks, %if.then ], [ null, %if.end36 ]
  ret i8** %retval.0

if.else77.1:                                      ; preds = %if.end89
  %95 = getelementptr inbounds i64, i64* %2, i64 %inc101
  %96 = load i64, i64* %95, align 8, !tbaa !8
  %cmp79.1 = icmp ult i64 %96, 23
  %add85.1 = add i64 %96, 23
  %and86.1 = and i64 %add85.1, -16
  %cond88.1 = select i1 %cmp79.1, i64 32, i64 %and86.1
  br label %if.end89.1

if.end89.1:                                       ; preds = %if.else77.1, %if.end89
  %size.0.1 = phi i64 [ %element_size.0, %if.end89 ], [ %cond88.1, %if.else77.1 ]
  %sub90.1 = sub i64 %sub90, %size.0.1
  %or92.1 = or i64 %size.0.1, 3
  %97 = getelementptr inbounds i8, i8* %add.ptr94, i64 8
  %98 = bitcast i8* %97 to i64*
  store i64 %or92.1, i64* %98, align 8, !tbaa !11
  %add.ptr94.1 = getelementptr inbounds i8, i8* %add.ptr94, i64 %size.0.1
  %99 = bitcast i8* %add.ptr94.1 to %struct.malloc_chunk*
  %inc101.1 = add i64 %i.1174, 2
  %add.ptr68.1 = getelementptr inbounds i8, i8* %add.ptr94.1, i64 16
  %100 = getelementptr inbounds i8*, i8** %81, i64 %inc101.1
  store i8* %add.ptr68.1, i8** %100, align 8, !tbaa !38
  %niter.nsub.1 = add i64 %niter, -2
  %niter.ncmp.1 = icmp eq i64 %niter.nsub.1, 0
  br i1 %niter.ncmp.1, label %if.else95.loopexit.unr-lcssa, label %if.then73
}

; Function Attrs: nounwind uwtable
define i8** @mspace_independent_comalloc(i8* %msp, i64 %n_elements, i64* %sizes, i8** %chunks) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** (%struct.malloc_state*, i64, i64*, i32, i8**)* @ialloc to i64*)) #7
  %1 = bitcast i64* %0 to i8** (%struct.malloc_state*, i64, i64*, i32, i8**)*
  %2 = bitcast i8* %msp to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = bitcast i8* %msp to %struct.malloc_state*
  %call = tail call i8** %1(%struct.malloc_state* %4, i64 %n_elements, i64* %sizes, i32 0, i8** %chunks) #7
  ret i8** %call
}

; Function Attrs: nounwind uwtable
define i64 @mspace_bulk_free(i8* %msp, i8** %array, i64 %nelem) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i64 (%struct.malloc_state*, i8**, i64)* @internal_bulk_free to i64*)) #7
  %1 = bitcast i64* %0 to i64 (%struct.malloc_state*, i8**, i64)*
  %2 = bitcast i8* %msp to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = bitcast i8* %msp to %struct.malloc_state*
  %call = tail call i64 %1(%struct.malloc_state* %4, i8** %array, i64 %nelem) #7
  ret i64 %call
}

; Function Attrs: nounwind uwtable
define internal i64 @internal_bulk_free(%struct.malloc_state* %m, i8** %array, i64 %nelem) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %1 = bitcast i64* %0 to void ()*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 (%struct.malloc_state*, i64)* @sys_trim to i64*)) #7
  %3 = bitcast i64* %2 to i32 (%struct.malloc_state*, i64)*
  %4 = bitcast %struct.malloc_state* %m to i64*
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %4) #7
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*, %struct.malloc_chunk*, i64)* @dispose_chunk to i64*)) #7
  %7 = bitcast i64* %6 to void (%struct.malloc_state*, %struct.malloc_chunk*, i64)*
  %8 = bitcast i8** %array to i64*
  %9 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %8) #7
  %arrayidx = getelementptr inbounds i8*, i8** %array, i64 %nelem
  %cmp68 = icmp eq i64 %nelem, 0
  br i1 %cmp68, label %for.end, label %for.body.lr.ph

for.body.lr.ph:                                   ; preds = %entry
  %10 = bitcast i64* %9 to i8**
  %11 = getelementptr inbounds i64, i64* %5, i64 3
  %12 = bitcast i64* %11 to i8**
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %if.end29
  %13 = phi i8** [ %10, %for.body.lr.ph ], [ %incdec.ptr.pre-phi, %if.end29 ]
  %a.069 = phi i8** [ %array, %for.body.lr.ph ], [ %incdec.ptr.pre-phi, %if.end29 ]
  %14 = load i8*, i8** %13, align 8, !tbaa !38
  %cmp1 = icmp eq i8* %14, null
  %15 = bitcast i8* %14 to i64*
  %16 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %15) #7
  br i1 %cmp1, label %for.body.if.end29_crit_edge, label %if.then

for.body.if.end29_crit_edge:                      ; preds = %for.body
  %.pre = getelementptr inbounds i8*, i8** %a.069, i64 1
  br label %if.end29

if.then:                                          ; preds = %for.body
  %add.ptr = getelementptr inbounds i8, i8* %14, i64 -16
  %17 = getelementptr inbounds i64, i64* %16, i64 -2
  %18 = bitcast i64* %17 to i8*
  %19 = bitcast i8* %add.ptr to %struct.malloc_chunk*
  %20 = getelementptr inbounds i64, i64* %16, i64 -1
  %21 = load i64, i64* %20, align 8, !tbaa !11
  %and = and i64 %21, -8
  store i8* null, i8** %13, align 8, !tbaa !38
  %22 = load i8*, i8** %12, align 8, !tbaa !14
  %cmp2 = icmp ult i8* %add.ptr, %22
  %and4 = and i64 %21, 3
  %cmp5 = icmp eq i64 %and4, 1
  %or.cond = or i1 %cmp2, %cmp5
  br i1 %or.cond, label %if.else27, label %if.then6, !prof !54

if.then6:                                         ; preds = %if.then
  %add.ptr7 = getelementptr inbounds i8*, i8** %a.069, i64 1
  %23 = getelementptr inbounds i8*, i8** %13, i64 1
  %24 = getelementptr inbounds i8, i8* %18, i64 %and
  %cmp11 = icmp eq i8** %add.ptr7, %arrayidx
  br i1 %cmp11, label %if.else, label %land.lhs.true

land.lhs.true:                                    ; preds = %if.then6
  %add.ptr10 = getelementptr inbounds i8, i8* %add.ptr, i64 %and
  %25 = load i8*, i8** %23, align 8, !tbaa !38
  %add.ptr13 = getelementptr inbounds i8, i8* %add.ptr10, i64 16
  %cmp14 = icmp eq i8* %25, %add.ptr13
  br i1 %cmp14, label %if.then16, label %if.else

if.then16:                                        ; preds = %land.lhs.true
  %26 = getelementptr inbounds i8, i8* %24, i64 8
  %27 = bitcast i8* %26 to i64*
  %28 = load i64, i64* %27, align 8, !tbaa !11
  %and18 = and i64 %28, -8
  %add = add i64 %and18, %and
  %and20 = and i64 %21, 1
  %or = or i64 %and20, %add
  %or21 = or i64 %or, 2
  store i64 %or21, i64* %20, align 8, !tbaa !11
  %29 = getelementptr inbounds i8, i8* %18, i64 %add
  %30 = getelementptr inbounds i8, i8* %29, i64 8
  %31 = bitcast i8* %30 to i64*
  %32 = load i64, i64* %31, align 8, !tbaa !11
  %or25 = or i64 %32, 1
  store i64 %or25, i64* %31, align 8, !tbaa !11
  store i8* %14, i8** %23, align 8, !tbaa !38
  br label %if.end29

if.else:                                          ; preds = %if.then6, %land.lhs.true
  tail call void %7(%struct.malloc_state* %m, %struct.malloc_chunk* %19, i64 %and) #7
  br label %if.end29

if.else27:                                        ; preds = %if.then
  tail call void %1() #8
  unreachable

if.end29:                                         ; preds = %for.body.if.end29_crit_edge, %if.then16, %if.else
  %incdec.ptr.pre-phi = phi i8** [ %.pre, %for.body.if.end29_crit_edge ], [ %add.ptr7, %if.then16 ], [ %add.ptr7, %if.else ]
  %cmp = icmp eq i8** %incdec.ptr.pre-phi, %arrayidx
  br i1 %cmp, label %for.end, label %for.body

for.end:                                          ; preds = %if.end29, %entry
  %33 = getelementptr inbounds i64, i64* %5, i64 2
  %34 = load i64, i64* %33, align 8, !tbaa !36
  %35 = getelementptr inbounds i64, i64* %5, i64 6
  %36 = load i64, i64* %35, align 8, !tbaa !47
  %cmp30 = icmp ugt i64 %34, %36
  br i1 %cmp30, label %if.then32, label %if.end33

if.then32:                                        ; preds = %for.end
  %call = tail call i32 %3(%struct.malloc_state* %m, i64 0) #7
  br label %if.end33

if.end33:                                         ; preds = %if.then32, %for.end
  ret i64 0
}

; Function Attrs: nounwind uwtable
define i32 @mspace_trim(i8* %msp, i64 %pad) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 (%struct.malloc_state*, i64)* @sys_trim to i64*)) #7
  %1 = bitcast i64* %0 to i32 (%struct.malloc_state*, i64)*
  %2 = bitcast i8* %msp to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = bitcast i8* %msp to %struct.malloc_state*
  %call = tail call i32 %1(%struct.malloc_state* %4, i64 %pad) #7
  ret i32 %call
}

; Function Attrs: nounwind uwtable
define void @mspace_malloc_stats(i8* %msp) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*)* @internal_malloc_stats to i64*)) #7
  %1 = bitcast i64* %0 to void (%struct.malloc_state*)*
  %2 = bitcast i8* %msp to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = bitcast i8* %msp to %struct.malloc_state*
  tail call void %1(%struct.malloc_state* %4) #7
  ret void
}

; Function Attrs: nounwind uwtable
define internal void @internal_malloc_stats(%struct.malloc_state* %m) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 (%struct._IO_FILE*, i8*, ...)* @fprintf to i64*)) #7
  %1 = bitcast i64* %0 to i32 (%struct._IO_FILE*, i8*, ...)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (%struct._IO_FILE** @stderr to i64*)) #7
  %3 = bitcast i64* %2 to %struct._IO_FILE**
  %4 = bitcast %struct.malloc_state* %m to i64*
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %4) #7
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 ()* @init_mparams to i64*)) #7
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %8 = load i64, i64* %7, align 8, !tbaa !1
  %cmp = icmp eq i64 %8, 0
  br i1 %cmp, label %lor.rhs, label %lor.end

lor.rhs:                                          ; preds = %entry
  %9 = bitcast i64* %6 to i32 ()*
  %call = tail call i32 %9() #7
  br label %lor.end

lor.end:                                          ; preds = %entry, %lor.rhs
  %10 = getelementptr inbounds i64, i64* %5, i64 5
  %11 = bitcast i64* %10 to %struct.malloc_chunk**
  %12 = load %struct.malloc_chunk*, %struct.malloc_chunk** %11, align 8, !tbaa !37
  %cmp1 = icmp eq %struct.malloc_chunk* %12, null
  br i1 %cmp1, label %if.end33, label %if.then

if.then:                                          ; preds = %lor.end
  %13 = getelementptr inbounds i64, i64* %5, i64 111
  %14 = bitcast i64* %13 to %struct.malloc_segment*
  %15 = getelementptr inbounds i64, i64* %5, i64 108
  %16 = load i64, i64* %15, align 8, !tbaa !18
  %17 = getelementptr inbounds i64, i64* %5, i64 107
  %18 = load i64, i64* %17, align 8, !tbaa !19
  %19 = getelementptr inbounds i64, i64* %5, i64 2
  %20 = load i64, i64* %19, align 8, !tbaa !36
  %add.neg = add i64 %18, -80
  %sub = sub i64 %add.neg, %20
  br label %while.body

while.body:                                       ; preds = %if.then, %while.end
  %21 = phi %struct.malloc_segment* [ %14, %if.then ], [ %47, %while.end ]
  %used.071 = phi i64 [ %sub, %if.then ], [ %used.1.lcssa, %while.end ]
  %22 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %21, i64 0, i32 0
  %23 = load i8*, i8** %22, align 8, !tbaa !48
  %24 = bitcast i8* %23 to i64*
  %25 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %24) #7
  %add.ptr = getelementptr inbounds i8, i8* %23, i64 16
  %26 = ptrtoint i8* %add.ptr to i64
  %and = and i64 %26, 15
  %cmp4 = icmp eq i64 %and, 0
  %sub8 = sub i64 0, %26
  %and9 = and i64 %sub8, 15
  %cond = select i1 %cmp4, i64 0, i64 %and9
  %add.ptr10 = getelementptr inbounds i8, i8* %23, i64 %cond
  %27 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %21, i64 0, i32 1
  %28 = load i8*, i8** %22, align 8, !tbaa !48
  %cmp1365 = icmp ult i8* %add.ptr10, %28
  %29 = bitcast i8* %28 to i64*
  %30 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %29) #7
  br i1 %cmp1365, label %while.end, label %land.lhs.true.preheader

land.lhs.true.preheader:                          ; preds = %while.body
  %31 = bitcast i64* %25 to i8*
  %32 = getelementptr inbounds i8, i8* %31, i64 %cond
  %33 = bitcast i8* %32 to %struct.malloc_chunk*
  %34 = bitcast i8* %add.ptr10 to %struct.malloc_chunk*
  br label %land.lhs.true

land.lhs.true:                                    ; preds = %land.lhs.true.preheader, %while.body21
  %35 = phi i8* [ %43, %while.body21 ], [ %28, %land.lhs.true.preheader ]
  %36 = phi %struct.malloc_chunk* [ %42, %while.body21 ], [ %33, %land.lhs.true.preheader ]
  %q.067 = phi %struct.malloc_chunk* [ %42, %while.body21 ], [ %34, %land.lhs.true.preheader ]
  %37 = phi i8* [ %add.ptr31, %while.body21 ], [ %add.ptr10, %land.lhs.true.preheader ]
  %used.166 = phi i64 [ %used.2, %while.body21 ], [ %used.071, %land.lhs.true.preheader ]
  %38 = load i64, i64* %27, align 8, !tbaa !55
  %add.ptr15 = getelementptr inbounds i8, i8* %35, i64 %38
  %cmp16 = icmp ult i8* %37, %add.ptr15
  br i1 %cmp16, label %land.lhs.true17, label %while.end

land.lhs.true17:                                  ; preds = %land.lhs.true
  %39 = load %struct.malloc_chunk*, %struct.malloc_chunk** %11, align 8, !tbaa !37
  %cmp19 = icmp eq %struct.malloc_chunk* %q.067, %39
  br i1 %cmp19, label %while.end, label %land.rhs

land.rhs:                                         ; preds = %land.lhs.true17
  %40 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %36, i64 0, i32 1
  %41 = load i64, i64* %40, align 8, !tbaa !11
  %cmp20 = icmp eq i64 %41, 11
  br i1 %cmp20, label %while.end, label %while.body21

while.body21:                                     ; preds = %land.rhs
  %and23 = and i64 %41, 3
  %cmp24 = icmp eq i64 %and23, 1
  %and27 = and i64 %41, -8
  %sub28 = select i1 %cmp24, i64 %and27, i64 0
  %used.2 = sub i64 %used.166, %sub28
  %add.ptr31 = getelementptr inbounds i8, i8* %37, i64 %and27
  %42 = bitcast i8* %add.ptr31 to %struct.malloc_chunk*
  %43 = load i8*, i8** %22, align 8, !tbaa !48
  %cmp13 = icmp ult i8* %add.ptr31, %43
  %44 = bitcast i8* %43 to i64*
  %45 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %44) #7
  br i1 %cmp13, label %while.end, label %land.lhs.true

while.end:                                        ; preds = %land.lhs.true, %while.body21, %land.lhs.true17, %land.rhs, %while.body
  %used.1.lcssa = phi i64 [ %used.071, %while.body ], [ %used.166, %land.rhs ], [ %used.166, %land.lhs.true17 ], [ %used.2, %while.body21 ], [ %used.166, %land.lhs.true ]
  %46 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %21, i64 0, i32 2
  %47 = load %struct.malloc_segment*, %struct.malloc_segment** %46, align 8, !tbaa !26
  %48 = bitcast %struct.malloc_segment* %47 to i64*
  %49 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %48) #7
  %cmp2 = icmp eq %struct.malloc_segment* %47, null
  br i1 %cmp2, label %if.end33, label %while.body

if.end33:                                         ; preds = %while.end, %lor.end
  %maxfp.0 = phi i64 [ 0, %lor.end ], [ %16, %while.end ]
  %fp.0 = phi i64 [ 0, %lor.end ], [ %18, %while.end ]
  %used.3 = phi i64 [ 0, %lor.end ], [ %used.1.lcssa, %while.end ]
  %50 = load %struct._IO_FILE*, %struct._IO_FILE** %3, align 8, !tbaa !38
  %call34 = tail call i32 (%struct._IO_FILE*, i8*, ...) %1(%struct._IO_FILE* %50, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.1, i64 0, i64 0), i64 %maxfp.0) #7
  %51 = load %struct._IO_FILE*, %struct._IO_FILE** %3, align 8, !tbaa !38
  %call35 = tail call i32 (%struct._IO_FILE*, i8*, ...) %1(%struct._IO_FILE* %51, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.2, i64 0, i64 0), i64 %fp.0) #7
  %52 = load %struct._IO_FILE*, %struct._IO_FILE** %3, align 8, !tbaa !38
  %call36 = tail call i32 (%struct._IO_FILE*, i8*, ...) %1(%struct._IO_FILE* %52, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.3, i64 0, i64 0), i64 %used.3) #7
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @mspace_footprint(i8* %msp) local_unnamed_addr #0 {
entry:
  %0 = bitcast i8* %msp to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  %2 = getelementptr inbounds i64, i64* %1, i64 107
  %3 = load i64, i64* %2, align 8, !tbaa !19
  ret i64 %3
}

; Function Attrs: nounwind uwtable
define i64 @mspace_max_footprint(i8* %msp) local_unnamed_addr #0 {
entry:
  %0 = bitcast i8* %msp to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  %2 = getelementptr inbounds i64, i64* %1, i64 108
  %3 = load i64, i64* %2, align 8, !tbaa !18
  ret i64 %3
}

; Function Attrs: nounwind uwtable
define i64 @mspace_footprint_limit(i8* %msp) local_unnamed_addr #0 {
entry:
  %0 = bitcast i8* %msp to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  %2 = getelementptr inbounds i64, i64* %1, i64 109
  %3 = load i64, i64* %2, align 8, !tbaa !46
  %cmp = icmp eq i64 %3, 0
  %cond = select i1 %cmp, i64 -1, i64 %3
  ret i64 %cond
}

; Function Attrs: nounwind uwtable
define i64 @mspace_set_footprint_limit(i8* %msp, i64 %bytes) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %1 = bitcast i8* %msp to i64*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %1) #7
  %cmp2 = icmp eq i64 %bytes, -1
  br i1 %cmp2, label %if.end9, label %if.else

if.else:                                          ; preds = %entry
  %3 = getelementptr i64, i64* %0, i64 2
  %4 = load i64, i64* %3, align 8, !tbaa !45
  %sub4 = add i64 %bytes, -1
  %add5 = add i64 %sub4, %4
  %neg7 = sub i64 0, %4
  %and8 = and i64 %add5, %neg7
  br label %if.end9

if.end9:                                          ; preds = %entry, %if.else
  %result.0 = phi i64 [ %and8, %if.else ], [ 0, %entry ]
  %5 = getelementptr inbounds i64, i64* %2, i64 109
  store i64 %result.0, i64* %5, align 8, !tbaa !46
  ret i64 %result.0
}

; Function Attrs: nounwind uwtable
define void @mspace_mallinfo(%struct.mallinfo* noalias sret %agg.result, i8* %msp) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.mallinfo*, %struct.malloc_state*)* @internal_mallinfo to i64*)) #7
  %1 = bitcast i64* %0 to void (%struct.mallinfo*, %struct.malloc_state*)*
  %2 = bitcast i8* %msp to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = bitcast i8* %msp to %struct.malloc_state*
  tail call void %1(%struct.mallinfo* sret %agg.result, %struct.malloc_state* %4) #7
  ret void
}

; Function Attrs: nounwind uwtable
define internal void @internal_mallinfo(%struct.mallinfo* noalias sret %agg.result, %struct.malloc_state* %m) #0 {
entry:
  %0 = getelementptr inbounds %struct.mallinfo, %struct.mallinfo* %agg.result, i64 0, i32 0
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  %2 = bitcast %struct.malloc_state* %m to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 ()* @init_mparams to i64*)) #7
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %nm.sroa.6 = alloca { i64, i64 }, align 8
  %nm.sroa.6.0..sroa_cast88 = bitcast { i64, i64 }* %nm.sroa.6 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %nm.sroa.6.0..sroa_cast88)
  call void @llvm.memset.p0i8.i64(i8* nonnull %nm.sroa.6.0..sroa_cast88, i8 0, i64 16, i32 8, i1 false)
  %6 = load i64, i64* %5, align 8, !tbaa !1
  %cmp = icmp eq i64 %6, 0
  br i1 %cmp, label %lor.rhs, label %lor.end

lor.rhs:                                          ; preds = %entry
  %7 = bitcast i64* %4 to i32 ()*
  %call = tail call i32 %7() #7
  br label %lor.end

lor.end:                                          ; preds = %entry, %lor.rhs
  %8 = getelementptr inbounds i64, i64* %3, i64 5
  %9 = bitcast i64* %8 to %struct.malloc_chunk**
  %10 = load %struct.malloc_chunk*, %struct.malloc_chunk** %9, align 8, !tbaa !37
  %cmp1 = icmp eq %struct.malloc_chunk* %10, null
  br i1 %cmp1, label %if.end37, label %if.then

if.then:                                          ; preds = %lor.end
  %11 = getelementptr inbounds i64, i64* %3, i64 2
  %12 = load i64, i64* %11, align 8, !tbaa !36
  %add = add i64 %12, 80
  %13 = getelementptr inbounds i64, i64* %3, i64 111
  %14 = bitcast i64* %13 to %struct.malloc_segment*
  br label %while.body

while.body:                                       ; preds = %if.then, %while.end
  %15 = phi %struct.malloc_segment* [ %14, %if.then ], [ %41, %while.end ]
  %sum.0116 = phi i64 [ %add, %if.then ], [ %sum.1.lcssa, %while.end ]
  %mfree.0115 = phi i64 [ %add, %if.then ], [ %mfree.1.lcssa, %while.end ]
  %nfree.0114 = phi i64 [ 1, %if.then ], [ %nfree.1.lcssa, %while.end ]
  %16 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %15, i64 0, i32 0
  %17 = load i8*, i8** %16, align 8, !tbaa !48
  %18 = bitcast i8* %17 to i64*
  %19 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %18) #7
  %add.ptr = getelementptr inbounds i8, i8* %17, i64 16
  %20 = ptrtoint i8* %add.ptr to i64
  %and = and i64 %20, 15
  %cmp4 = icmp eq i64 %and, 0
  %sub = sub i64 0, %20
  %and8 = and i64 %sub, 15
  %cond = select i1 %cmp4, i64 0, i64 %and8
  %add.ptr9 = getelementptr inbounds i8, i8* %17, i64 %cond
  %21 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %15, i64 0, i32 1
  %22 = load i8*, i8** %16, align 8, !tbaa !48
  %cmp1298 = icmp ult i8* %add.ptr9, %22
  %23 = bitcast i8* %22 to i64*
  %24 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %23) #7
  br i1 %cmp1298, label %while.end, label %land.lhs.true.preheader

land.lhs.true.preheader:                          ; preds = %while.body
  %25 = bitcast i64* %19 to i8*
  %26 = getelementptr inbounds i8, i8* %25, i64 %cond
  %27 = bitcast i8* %26 to %struct.malloc_chunk*
  %28 = bitcast i8* %add.ptr9 to %struct.malloc_chunk*
  br label %land.lhs.true

land.lhs.true:                                    ; preds = %land.lhs.true.preheader, %while.body20
  %29 = phi i8* [ %37, %while.body20 ], [ %22, %land.lhs.true.preheader ]
  %30 = phi %struct.malloc_chunk* [ %36, %while.body20 ], [ %27, %land.lhs.true.preheader ]
  %q.0102 = phi %struct.malloc_chunk* [ %36, %while.body20 ], [ %28, %land.lhs.true.preheader ]
  %31 = phi i8* [ %add.ptr31, %while.body20 ], [ %add.ptr9, %land.lhs.true.preheader ]
  %sum.1101 = phi i64 [ %add23, %while.body20 ], [ %sum.0116, %land.lhs.true.preheader ]
  %mfree.1100 = phi i64 [ %mfree.2, %while.body20 ], [ %mfree.0115, %land.lhs.true.preheader ]
  %nfree.199 = phi i64 [ %nfree.2, %while.body20 ], [ %nfree.0114, %land.lhs.true.preheader ]
  %32 = load i64, i64* %21, align 8, !tbaa !55
  %add.ptr14 = getelementptr inbounds i8, i8* %29, i64 %32
  %cmp15 = icmp ult i8* %31, %add.ptr14
  br i1 %cmp15, label %land.lhs.true16, label %while.end

land.lhs.true16:                                  ; preds = %land.lhs.true
  %33 = load %struct.malloc_chunk*, %struct.malloc_chunk** %9, align 8, !tbaa !37
  %cmp18 = icmp eq %struct.malloc_chunk* %q.0102, %33
  br i1 %cmp18, label %while.end, label %land.rhs

land.rhs:                                         ; preds = %land.lhs.true16
  %34 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %30, i64 0, i32 1
  %35 = load i64, i64* %34, align 8, !tbaa !11
  %cmp19 = icmp eq i64 %35, 11
  br i1 %cmp19, label %while.end, label %while.body20

while.body20:                                     ; preds = %land.rhs
  %and22 = and i64 %35, -8
  %add23 = add i64 %and22, %sum.1101
  %and25 = and i64 %35, 3
  %cmp26 = icmp eq i64 %and25, 1
  %inc = zext i1 %cmp26 to i64
  %nfree.2 = add i64 %nfree.199, %inc
  %add28 = select i1 %cmp26, i64 %and22, i64 0
  %mfree.2 = add i64 %add28, %mfree.1100
  %add.ptr31 = getelementptr inbounds i8, i8* %31, i64 %and22
  %36 = bitcast i8* %add.ptr31 to %struct.malloc_chunk*
  %37 = load i8*, i8** %16, align 8, !tbaa !48
  %cmp12 = icmp ult i8* %add.ptr31, %37
  %38 = bitcast i8* %37 to i64*
  %39 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %38) #7
  br i1 %cmp12, label %while.end, label %land.lhs.true

while.end:                                        ; preds = %land.lhs.true, %while.body20, %land.lhs.true16, %land.rhs, %while.body
  %nfree.1.lcssa = phi i64 [ %nfree.0114, %while.body ], [ %nfree.199, %land.rhs ], [ %nfree.199, %land.lhs.true16 ], [ %nfree.2, %while.body20 ], [ %nfree.199, %land.lhs.true ]
  %mfree.1.lcssa = phi i64 [ %mfree.0115, %while.body ], [ %mfree.1100, %land.rhs ], [ %mfree.1100, %land.lhs.true16 ], [ %mfree.2, %while.body20 ], [ %mfree.1100, %land.lhs.true ]
  %sum.1.lcssa = phi i64 [ %sum.0116, %while.body ], [ %sum.1101, %land.rhs ], [ %sum.1101, %land.lhs.true16 ], [ %add23, %while.body20 ], [ %sum.1101, %land.lhs.true ]
  %40 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %15, i64 0, i32 2
  %41 = load %struct.malloc_segment*, %struct.malloc_segment** %40, align 8, !tbaa !26
  %42 = bitcast %struct.malloc_segment* %41 to i64*
  %43 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %42) #7
  %cmp2 = icmp eq %struct.malloc_segment* %41, null
  br i1 %cmp2, label %while.end32, label %while.body

while.end32:                                      ; preds = %while.end
  %44 = getelementptr inbounds i64, i64* %3, i64 107
  %45 = load i64, i64* %44, align 8, !tbaa !19
  %sub33 = sub i64 %45, %sum.1.lcssa
  %46 = getelementptr inbounds i64, i64* %3, i64 108
  %47 = load i64, i64* %46, align 8, !tbaa !18
  %sub35 = sub i64 %45, %mfree.1.lcssa
  %48 = load i64, i64* %11, align 8, !tbaa !36
  br label %if.end37

if.end37:                                         ; preds = %lor.end, %while.end32
  %nm.sroa.881.0 = phi i64 [ %sub35, %while.end32 ], [ 0, %lor.end ]
  %nm.sroa.9.0 = phi i64 [ %mfree.1.lcssa, %while.end32 ], [ 0, %lor.end ]
  %nm.sroa.7.0 = phi i64 [ %47, %while.end32 ], [ 0, %lor.end ]
  %nm.sroa.674.0 = phi i64 [ %sub33, %while.end32 ], [ 0, %lor.end ]
  %nm.sroa.5.0 = phi i64 [ %nfree.1.lcssa, %while.end32 ], [ 0, %lor.end ]
  %nm.sroa.0.0 = phi i64 [ %sum.1.lcssa, %while.end32 ], [ 0, %lor.end ]
  %nm.sroa.10.0 = phi i64 [ %48, %while.end32 ], [ 0, %lor.end ]
  store i64 %nm.sroa.0.0, i64* %1, align 8
  %49 = getelementptr inbounds i64, i64* %1, i64 1
  store i64 %nm.sroa.5.0, i64* %49, align 8
  %50 = getelementptr inbounds i64, i64* %1, i64 2
  %51 = bitcast i64* %50 to i8*
  %52 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %nm.sroa.6, i64 0, i32 0
  %53 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* nonnull %52) #7
  %54 = bitcast i64* %53 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %51, i8* %54, i64 16, i32 8, i1 false)
  %55 = getelementptr inbounds i64, i64* %1, i64 4
  store i64 %nm.sroa.674.0, i64* %55, align 8
  %56 = getelementptr inbounds i64, i64* %1, i64 5
  store i64 %nm.sroa.7.0, i64* %56, align 8
  %57 = getelementptr inbounds i64, i64* %1, i64 6
  store i64 0, i64* %57, align 8
  %58 = getelementptr inbounds i64, i64* %1, i64 7
  store i64 %nm.sroa.881.0, i64* %58, align 8
  %59 = getelementptr inbounds i64, i64* %1, i64 8
  store i64 %nm.sroa.9.0, i64* %59, align 8
  %60 = getelementptr inbounds i64, i64* %1, i64 9
  store i64 %nm.sroa.10.0, i64* %60, align 8
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %nm.sroa.6.0..sroa_cast88)
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @mspace_usable_size(i8* %mem) #0 {
entry:
  %0 = bitcast i8* %mem to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  %cmp = icmp eq i8* %mem, null
  br i1 %cmp, label %return, label %if.then

if.then:                                          ; preds = %entry
  %2 = getelementptr inbounds i64, i64* %1, i64 -1
  %3 = load i64, i64* %2, align 8, !tbaa !11
  %and = and i64 %3, 3
  %cmp1 = icmp eq i64 %and, 1
  br i1 %cmp1, label %return, label %cleanup

cleanup:                                          ; preds = %if.then
  %and4 = and i64 %3, -8
  %cmp7 = icmp eq i64 %and, 0
  %cond = select i1 %cmp7, i64 16, i64 8
  %sub = sub i64 %and4, %cond
  br label %return

return:                                           ; preds = %if.then, %entry, %cleanup
  %retval.1 = phi i64 [ %sub, %cleanup ], [ 0, %entry ], [ 0, %if.then ]
  ret i64 %retval.1
}

; Function Attrs: nounwind uwtable
define i32 @mspace_mallopt(i32 %param_number, i32 %value) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 (i32, i32)* @change_mparam to i64*)) #7
  %1 = bitcast i64* %0 to i32 (i32, i32)*
  %call = tail call i32 %1(i32 %param_number, i32 %value) #7
  ret i32 %call
}

; Function Attrs: nounwind uwtable
define internal i32 @change_mparam(i32 %param_number, i32 %value) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i32 ()* @init_mparams to i64*)) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %2 = load i64, i64* %1, align 8, !tbaa !1
  %cmp = icmp eq i64 %2, 0
  br i1 %cmp, label %lor.rhs, label %lor.end

lor.rhs:                                          ; preds = %entry
  %3 = bitcast i64* %0 to i32 ()*
  %call = tail call i32 %3() #7
  br label %lor.end

lor.end:                                          ; preds = %entry, %lor.rhs
  %conv = sext i32 %value to i64
  switch i32 %param_number, label %cleanup [
    i32 -1, label %sw.bb
    i32 -2, label %sw.bb2
    i32 -3, label %sw.bb7
  ]

sw.bb:                                            ; preds = %lor.end
  %4 = getelementptr i64, i64* %1, i64 4
  store i64 %conv, i64* %4, align 8, !tbaa !9
  br label %cleanup

sw.bb2:                                           ; preds = %lor.end
  %5 = getelementptr i64, i64* %1, i64 1
  %6 = load i64, i64* %5, align 8, !tbaa !7
  %cmp3 = icmp ugt i64 %6, %conv
  br i1 %cmp3, label %cleanup, label %land.lhs.true

land.lhs.true:                                    ; preds = %sw.bb2
  %sub = add nsw i64 %conv, -1
  %and = and i64 %sub, %conv
  %cmp5 = icmp eq i64 %and, 0
  br i1 %cmp5, label %if.then, label %cleanup

if.then:                                          ; preds = %land.lhs.true
  %7 = getelementptr i64, i64* %1, i64 2
  store i64 %conv, i64* %7, align 8, !tbaa !45
  br label %cleanup

sw.bb7:                                           ; preds = %lor.end
  %8 = getelementptr i64, i64* %1, i64 3
  store i64 %conv, i64* %8, align 8, !tbaa !56
  br label %cleanup

cleanup:                                          ; preds = %lor.end, %land.lhs.true, %sw.bb2, %sw.bb7, %if.then, %sw.bb
  %retval.0 = phi i32 [ 1, %sw.bb7 ], [ 1, %if.then ], [ 1, %sw.bb ], [ 0, %sw.bb2 ], [ 0, %land.lhs.true ], [ 0, %lor.end ]
  ret i32 %retval.0
}

; Function Attrs: nounwind uwtable
define void @_malloc_init() #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_ms to i64*)) #7
  %1 = bitcast i64* %0 to i8**
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64, i32)* @create_mspace_with_base to i64*)) #7
  %3 = bitcast i64* %2 to i8* (i8*, i64, i32)*
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_heap to i64*)) #7
  %5 = bitcast i64* %4 to i8**
  %6 = load i8*, i8** %5, align 8, !tbaa !38
  %call = tail call i8* %3(i8* %6, i64 8388608, i32 0) #7
  store i8* %call, i8** %1, align 8, !tbaa !38
  ret void
}

; Function Attrs: nounwind uwtable
define noalias i8* @malloc(i64 %bytes) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64)* @mspace_malloc to i64*)) #7
  %1 = bitcast i64* %0 to i8* (i8*, i64)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @_malloc_init to i64*)) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_ms to i64*)) #7
  %4 = bitcast i64* %3 to i8**
  %5 = load i8*, i8** %4, align 8, !tbaa !38
  %tobool = icmp eq i8* %5, null
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %6 = bitcast i64* %2 to void ()*
  tail call void %6() #7
  %.pre = load i8*, i8** %4, align 8, !tbaa !38
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %7 = phi i8* [ %5, %entry ], [ %.pre, %if.then ]
  %call = tail call i8* %1(i8* %7, i64 %bytes) #7
  ret i8* %call
}

; Function Attrs: nounwind uwtable
define void @free(i8* %mem) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (i8*, i8*)* @mspace_free to i64*)) #7
  %1 = bitcast i64* %0 to void (i8*, i8*)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @_malloc_init to i64*)) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_ms to i64*)) #7
  %4 = bitcast i64* %3 to i8**
  %5 = load i8*, i8** %4, align 8, !tbaa !38
  %tobool = icmp eq i8* %5, null
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %6 = bitcast i64* %2 to void ()*
  tail call void %6() #7
  %.pre = load i8*, i8** %4, align 8, !tbaa !38
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %7 = phi i8* [ %5, %entry ], [ %.pre, %if.then ]
  tail call void %1(i8* %7, i8* %mem) #7
  ret void
}

; Function Attrs: nounwind uwtable
define noalias i8* @calloc(i64 %n_elements, i64 %elem_size) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64, i64)* @mspace_calloc to i64*)) #7
  %1 = bitcast i64* %0 to i8* (i8*, i64, i64)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @_malloc_init to i64*)) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_ms to i64*)) #7
  %4 = bitcast i64* %3 to i8**
  %5 = load i8*, i8** %4, align 8, !tbaa !38
  %tobool = icmp eq i8* %5, null
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %6 = bitcast i64* %2 to void ()*
  tail call void %6() #7
  %.pre = load i8*, i8** %4, align 8, !tbaa !38
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %7 = phi i8* [ %5, %entry ], [ %.pre, %if.then ]
  %call = tail call i8* %1(i8* %7, i64 %n_elements, i64 %elem_size) #7
  ret i8* %call
}

; Function Attrs: nounwind uwtable
define i8* @realloc(i8* %oldMem, i64 %bytes) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i8*, i64)* @mspace_realloc to i64*)) #7
  %1 = bitcast i64* %0 to i8* (i8*, i8*, i64)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @_malloc_init to i64*)) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_ms to i64*)) #7
  %4 = bitcast i64* %3 to i8**
  %5 = load i8*, i8** %4, align 8, !tbaa !38
  %tobool = icmp eq i8* %5, null
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %6 = bitcast i64* %2 to void ()*
  tail call void %6() #7
  %.pre = load i8*, i8** %4, align 8, !tbaa !38
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %7 = phi i8* [ %5, %entry ], [ %.pre, %if.then ]
  %call = tail call i8* %1(i8* %7, i8* %oldMem, i64 %bytes) #7
  ret i8* %call
}

; Function Attrs: nounwind uwtable
define i8* @memalign(i64 %alignment, i64 %bytes) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64, i64)* @mspace_memalign to i64*)) #7
  %1 = bitcast i64* %0 to i8* (i8*, i64, i64)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @_malloc_init to i64*)) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_ms to i64*)) #7
  %4 = bitcast i64* %3 to i8**
  %5 = load i8*, i8** %4, align 8, !tbaa !38
  %tobool = icmp eq i8* %5, null
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %6 = bitcast i64* %2 to void ()*
  tail call void %6() #7
  %.pre = load i8*, i8** %4, align 8, !tbaa !38
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %7 = phi i8* [ %5, %entry ], [ %.pre, %if.then ]
  %call = tail call i8* %1(i8* %7, i64 %alignment, i64 %bytes) #7
  ret i8* %call
}

; Function Attrs: nounwind uwtable
define i64 @malloc_usable_size(i8* %mem) local_unnamed_addr #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i64 (i8*)* @mspace_usable_size to i64*)) #7
  %1 = bitcast i64* %0 to i64 (i8*)*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @_malloc_init to i64*)) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_ms to i64*)) #7
  %4 = bitcast i64* %3 to i8**
  %5 = load i8*, i8** %4, align 8, !tbaa !38
  %tobool = icmp eq i8* %5, null
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %6 = bitcast i64* %2 to void ()*
  tail call void %6() #7
  br label %if.end

if.end:                                           ; preds = %entry, %if.then
  %call = tail call i64 %1(i8* %mem) #7
  ret i64 %call
}

; Function Attrs: nounwind uwtable
define i32 @posix_memalign(i8** nonnull %memptr, i64 %alignment, i64 %bytes) local_unnamed_addr #0 {
entry:
  %0 = bitcast i8** %memptr to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* nonnull %0) #7
  %2 = bitcast i64* %1 to i8**
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8* (i8*, i64, i64)* @mspace_memalign to i64*)) #7
  %4 = bitcast i64* %3 to i8* (i8*, i64, i64)*
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @_malloc_init to i64*)) #7
  %6 = bitcast i64* %5 to void ()*
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (i8** @_ms to i64*)) #7
  %8 = bitcast i64* %7 to i8**
  %cmp = icmp ult i64 %alignment, 8
  br i1 %cmp, label %return, label %if.end2

if.end2:                                          ; preds = %entry
  %9 = load i8*, i8** %8, align 8, !tbaa !38
  %tobool3 = icmp eq i8* %9, null
  br i1 %tobool3, label %if.then4, label %if.end5

if.then4:                                         ; preds = %if.end2
  tail call void %6() #7
  %.pre = load i8*, i8** %8, align 8, !tbaa !38
  br label %if.end5

if.end5:                                          ; preds = %if.end2, %if.then4
  %10 = phi i8* [ %9, %if.end2 ], [ %.pre, %if.then4 ]
  %call = tail call i8* %4(i8* %10, i64 %alignment, i64 %bytes) #7
  store i8* %call, i8** %2, align 8, !tbaa !38
  %tobool6 = icmp eq i8* %call, null
  %. = zext i1 %tobool6 to i32
  br label %return

return:                                           ; preds = %if.end5, %entry
  %retval.0 = phi i32 [ 22, %entry ], [ %., %if.end5 ]
  ret i32 %retval.0
}

; Function Attrs: nounwind
declare i64 @sysconf(i32) #6

; Function Attrs: nounwind uwtable
define internal void @init_bins(%struct.malloc_state* %m) #0 {
entry:
  %0 = bitcast %struct.malloc_state* %m to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  %arrayidx = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 0
  %2 = getelementptr inbounds i64, i64* %1, i64 12
  %3 = bitcast i64* %2 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx, %struct.malloc_chunk*** %3, align 8, !tbaa !29
  %4 = getelementptr inbounds i64, i64* %1, i64 11
  %5 = bitcast i64* %4 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx, %struct.malloc_chunk*** %5, align 8, !tbaa !28
  %arrayidx.1 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 2
  %6 = getelementptr inbounds i64, i64* %1, i64 14
  %7 = bitcast i64* %6 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.1, %struct.malloc_chunk*** %7, align 8, !tbaa !29
  %8 = getelementptr inbounds i64, i64* %1, i64 13
  %9 = bitcast i64* %8 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.1, %struct.malloc_chunk*** %9, align 8, !tbaa !28
  %arrayidx.2 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 4
  %10 = getelementptr inbounds i64, i64* %1, i64 16
  %11 = bitcast i64* %10 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.2, %struct.malloc_chunk*** %11, align 8, !tbaa !29
  %12 = getelementptr inbounds i64, i64* %1, i64 15
  %13 = bitcast i64* %12 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.2, %struct.malloc_chunk*** %13, align 8, !tbaa !28
  %arrayidx.3 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 6
  %14 = getelementptr inbounds i64, i64* %1, i64 18
  %15 = bitcast i64* %14 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.3, %struct.malloc_chunk*** %15, align 8, !tbaa !29
  %16 = getelementptr inbounds i64, i64* %1, i64 17
  %17 = bitcast i64* %16 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.3, %struct.malloc_chunk*** %17, align 8, !tbaa !28
  %arrayidx.4 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 8
  %18 = getelementptr inbounds i64, i64* %1, i64 20
  %19 = bitcast i64* %18 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.4, %struct.malloc_chunk*** %19, align 8, !tbaa !29
  %20 = getelementptr inbounds i64, i64* %1, i64 19
  %21 = bitcast i64* %20 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.4, %struct.malloc_chunk*** %21, align 8, !tbaa !28
  %arrayidx.5 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 10
  %22 = getelementptr inbounds i64, i64* %1, i64 22
  %23 = bitcast i64* %22 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.5, %struct.malloc_chunk*** %23, align 8, !tbaa !29
  %24 = getelementptr inbounds i64, i64* %1, i64 21
  %25 = bitcast i64* %24 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.5, %struct.malloc_chunk*** %25, align 8, !tbaa !28
  %arrayidx.6 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 12
  %26 = getelementptr inbounds i64, i64* %1, i64 24
  %27 = bitcast i64* %26 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.6, %struct.malloc_chunk*** %27, align 8, !tbaa !29
  %28 = getelementptr inbounds i64, i64* %1, i64 23
  %29 = bitcast i64* %28 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.6, %struct.malloc_chunk*** %29, align 8, !tbaa !28
  %arrayidx.7 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 14
  %30 = getelementptr inbounds i64, i64* %1, i64 26
  %31 = bitcast i64* %30 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.7, %struct.malloc_chunk*** %31, align 8, !tbaa !29
  %32 = getelementptr inbounds i64, i64* %1, i64 25
  %33 = bitcast i64* %32 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.7, %struct.malloc_chunk*** %33, align 8, !tbaa !28
  %arrayidx.8 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 16
  %34 = getelementptr inbounds i64, i64* %1, i64 28
  %35 = bitcast i64* %34 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.8, %struct.malloc_chunk*** %35, align 8, !tbaa !29
  %36 = getelementptr inbounds i64, i64* %1, i64 27
  %37 = bitcast i64* %36 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.8, %struct.malloc_chunk*** %37, align 8, !tbaa !28
  %arrayidx.9 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 18
  %38 = getelementptr inbounds i64, i64* %1, i64 30
  %39 = bitcast i64* %38 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.9, %struct.malloc_chunk*** %39, align 8, !tbaa !29
  %40 = getelementptr inbounds i64, i64* %1, i64 29
  %41 = bitcast i64* %40 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.9, %struct.malloc_chunk*** %41, align 8, !tbaa !28
  %arrayidx.10 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 20
  %42 = getelementptr inbounds i64, i64* %1, i64 32
  %43 = bitcast i64* %42 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.10, %struct.malloc_chunk*** %43, align 8, !tbaa !29
  %44 = getelementptr inbounds i64, i64* %1, i64 31
  %45 = bitcast i64* %44 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.10, %struct.malloc_chunk*** %45, align 8, !tbaa !28
  %arrayidx.11 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 22
  %46 = getelementptr inbounds i64, i64* %1, i64 34
  %47 = bitcast i64* %46 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.11, %struct.malloc_chunk*** %47, align 8, !tbaa !29
  %48 = getelementptr inbounds i64, i64* %1, i64 33
  %49 = bitcast i64* %48 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.11, %struct.malloc_chunk*** %49, align 8, !tbaa !28
  %arrayidx.12 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 24
  %50 = getelementptr inbounds i64, i64* %1, i64 36
  %51 = bitcast i64* %50 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.12, %struct.malloc_chunk*** %51, align 8, !tbaa !29
  %52 = getelementptr inbounds i64, i64* %1, i64 35
  %53 = bitcast i64* %52 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.12, %struct.malloc_chunk*** %53, align 8, !tbaa !28
  %arrayidx.13 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 26
  %54 = getelementptr inbounds i64, i64* %1, i64 38
  %55 = bitcast i64* %54 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.13, %struct.malloc_chunk*** %55, align 8, !tbaa !29
  %56 = getelementptr inbounds i64, i64* %1, i64 37
  %57 = bitcast i64* %56 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.13, %struct.malloc_chunk*** %57, align 8, !tbaa !28
  %arrayidx.14 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 28
  %58 = getelementptr inbounds i64, i64* %1, i64 40
  %59 = bitcast i64* %58 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.14, %struct.malloc_chunk*** %59, align 8, !tbaa !29
  %60 = getelementptr inbounds i64, i64* %1, i64 39
  %61 = bitcast i64* %60 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.14, %struct.malloc_chunk*** %61, align 8, !tbaa !28
  %arrayidx.15 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 30
  %62 = getelementptr inbounds i64, i64* %1, i64 42
  %63 = bitcast i64* %62 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.15, %struct.malloc_chunk*** %63, align 8, !tbaa !29
  %64 = getelementptr inbounds i64, i64* %1, i64 41
  %65 = bitcast i64* %64 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.15, %struct.malloc_chunk*** %65, align 8, !tbaa !28
  %arrayidx.16 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 32
  %66 = getelementptr inbounds i64, i64* %1, i64 44
  %67 = bitcast i64* %66 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.16, %struct.malloc_chunk*** %67, align 8, !tbaa !29
  %68 = getelementptr inbounds i64, i64* %1, i64 43
  %69 = bitcast i64* %68 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.16, %struct.malloc_chunk*** %69, align 8, !tbaa !28
  %arrayidx.17 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 34
  %70 = getelementptr inbounds i64, i64* %1, i64 46
  %71 = bitcast i64* %70 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.17, %struct.malloc_chunk*** %71, align 8, !tbaa !29
  %72 = getelementptr inbounds i64, i64* %1, i64 45
  %73 = bitcast i64* %72 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.17, %struct.malloc_chunk*** %73, align 8, !tbaa !28
  %arrayidx.18 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 36
  %74 = getelementptr inbounds i64, i64* %1, i64 48
  %75 = bitcast i64* %74 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.18, %struct.malloc_chunk*** %75, align 8, !tbaa !29
  %76 = getelementptr inbounds i64, i64* %1, i64 47
  %77 = bitcast i64* %76 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.18, %struct.malloc_chunk*** %77, align 8, !tbaa !28
  %arrayidx.19 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 38
  %78 = getelementptr inbounds i64, i64* %1, i64 50
  %79 = bitcast i64* %78 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.19, %struct.malloc_chunk*** %79, align 8, !tbaa !29
  %80 = getelementptr inbounds i64, i64* %1, i64 49
  %81 = bitcast i64* %80 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.19, %struct.malloc_chunk*** %81, align 8, !tbaa !28
  %arrayidx.20 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 40
  %82 = getelementptr inbounds i64, i64* %1, i64 52
  %83 = bitcast i64* %82 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.20, %struct.malloc_chunk*** %83, align 8, !tbaa !29
  %84 = getelementptr inbounds i64, i64* %1, i64 51
  %85 = bitcast i64* %84 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.20, %struct.malloc_chunk*** %85, align 8, !tbaa !28
  %arrayidx.21 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 42
  %86 = getelementptr inbounds i64, i64* %1, i64 54
  %87 = bitcast i64* %86 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.21, %struct.malloc_chunk*** %87, align 8, !tbaa !29
  %88 = getelementptr inbounds i64, i64* %1, i64 53
  %89 = bitcast i64* %88 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.21, %struct.malloc_chunk*** %89, align 8, !tbaa !28
  %arrayidx.22 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 44
  %90 = getelementptr inbounds i64, i64* %1, i64 56
  %91 = bitcast i64* %90 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.22, %struct.malloc_chunk*** %91, align 8, !tbaa !29
  %92 = getelementptr inbounds i64, i64* %1, i64 55
  %93 = bitcast i64* %92 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.22, %struct.malloc_chunk*** %93, align 8, !tbaa !28
  %arrayidx.23 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 46
  %94 = getelementptr inbounds i64, i64* %1, i64 58
  %95 = bitcast i64* %94 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.23, %struct.malloc_chunk*** %95, align 8, !tbaa !29
  %96 = getelementptr inbounds i64, i64* %1, i64 57
  %97 = bitcast i64* %96 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.23, %struct.malloc_chunk*** %97, align 8, !tbaa !28
  %arrayidx.24 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 48
  %98 = getelementptr inbounds i64, i64* %1, i64 60
  %99 = bitcast i64* %98 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.24, %struct.malloc_chunk*** %99, align 8, !tbaa !29
  %100 = getelementptr inbounds i64, i64* %1, i64 59
  %101 = bitcast i64* %100 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.24, %struct.malloc_chunk*** %101, align 8, !tbaa !28
  %arrayidx.25 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 50
  %102 = getelementptr inbounds i64, i64* %1, i64 62
  %103 = bitcast i64* %102 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.25, %struct.malloc_chunk*** %103, align 8, !tbaa !29
  %104 = getelementptr inbounds i64, i64* %1, i64 61
  %105 = bitcast i64* %104 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.25, %struct.malloc_chunk*** %105, align 8, !tbaa !28
  %arrayidx.26 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 52
  %106 = getelementptr inbounds i64, i64* %1, i64 64
  %107 = bitcast i64* %106 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.26, %struct.malloc_chunk*** %107, align 8, !tbaa !29
  %108 = getelementptr inbounds i64, i64* %1, i64 63
  %109 = bitcast i64* %108 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.26, %struct.malloc_chunk*** %109, align 8, !tbaa !28
  %arrayidx.27 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 54
  %110 = getelementptr inbounds i64, i64* %1, i64 66
  %111 = bitcast i64* %110 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.27, %struct.malloc_chunk*** %111, align 8, !tbaa !29
  %112 = getelementptr inbounds i64, i64* %1, i64 65
  %113 = bitcast i64* %112 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.27, %struct.malloc_chunk*** %113, align 8, !tbaa !28
  %arrayidx.28 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 56
  %114 = getelementptr inbounds i64, i64* %1, i64 68
  %115 = bitcast i64* %114 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.28, %struct.malloc_chunk*** %115, align 8, !tbaa !29
  %116 = getelementptr inbounds i64, i64* %1, i64 67
  %117 = bitcast i64* %116 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.28, %struct.malloc_chunk*** %117, align 8, !tbaa !28
  %arrayidx.29 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 58
  %118 = getelementptr inbounds i64, i64* %1, i64 70
  %119 = bitcast i64* %118 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.29, %struct.malloc_chunk*** %119, align 8, !tbaa !29
  %120 = getelementptr inbounds i64, i64* %1, i64 69
  %121 = bitcast i64* %120 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.29, %struct.malloc_chunk*** %121, align 8, !tbaa !28
  %arrayidx.30 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 60
  %122 = getelementptr inbounds i64, i64* %1, i64 72
  %123 = bitcast i64* %122 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.30, %struct.malloc_chunk*** %123, align 8, !tbaa !29
  %124 = getelementptr inbounds i64, i64* %1, i64 71
  %125 = bitcast i64* %124 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.30, %struct.malloc_chunk*** %125, align 8, !tbaa !28
  %arrayidx.31 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 62
  %126 = getelementptr inbounds i64, i64* %1, i64 74
  %127 = bitcast i64* %126 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.31, %struct.malloc_chunk*** %127, align 8, !tbaa !29
  %128 = getelementptr inbounds i64, i64* %1, i64 73
  %129 = bitcast i64* %128 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx.31, %struct.malloc_chunk*** %129, align 8, !tbaa !28
  ret void
}

; Function Attrs: nounwind uwtable
define internal void @init_top(%struct.malloc_state* %m, %struct.malloc_chunk* %p, i64 %psize) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %1 = bitcast %struct.malloc_state* %m to i64*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %1) #7
  %3 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %p, i64 0, i32 0
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %3) #7
  %5 = bitcast %struct.malloc_chunk* %p to i8*
  %6 = bitcast i64* %4 to i8*
  %add.ptr = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %p, i64 0, i32 2
  %7 = ptrtoint %struct.malloc_chunk** %add.ptr to i64
  %and = and i64 %7, 15
  %cmp = icmp eq i64 %and, 0
  %sub = sub i64 0, %7
  %and3 = and i64 %sub, 15
  %cond = select i1 %cmp, i64 0, i64 %and3
  %add.ptr4 = getelementptr inbounds i8, i8* %5, i64 %cond
  %8 = getelementptr inbounds i8, i8* %6, i64 %cond
  %sub5 = sub i64 %psize, %cond
  %9 = getelementptr inbounds i64, i64* %2, i64 5
  %10 = bitcast i64* %9 to i8**
  store i8* %add.ptr4, i8** %10, align 8, !tbaa !37
  %11 = getelementptr inbounds i64, i64* %2, i64 2
  store i64 %sub5, i64* %11, align 8, !tbaa !36
  %or = or i64 %sub5, 1
  %12 = getelementptr inbounds i8, i8* %8, i64 8
  %13 = bitcast i8* %12 to i64*
  store i64 %or, i64* %13, align 8, !tbaa !11
  %14 = getelementptr inbounds i8, i8* %6, i64 %psize
  %15 = getelementptr inbounds i8, i8* %14, i64 8
  %16 = bitcast i8* %15 to i64*
  store i64 80, i64* %16, align 8, !tbaa !11
  %17 = getelementptr i64, i64* %0, i64 4
  %18 = load i64, i64* %17, align 8, !tbaa !9
  %19 = getelementptr inbounds i64, i64* %2, i64 6
  store i64 %18, i64* %19, align 8, !tbaa !47
  ret void
}

; Function Attrs: nounwind uwtable
define internal noalias i8* @mmap_alloc(%struct.malloc_state* %m, i64 %nb) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* inttoptr (i64 -1 to i64*)) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %2 = bitcast %struct.malloc_state* %m to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  ret i8* null
}

; Function Attrs: nounwind uwtable
define internal i8* @prepend_alloc(%struct.malloc_state* %m, i8* %newbase, i8* %oldbase, i64 %nb) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %1 = bitcast i64* %0 to void ()*
  %2 = bitcast %struct.malloc_state* %m to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = bitcast i64* %3 to %struct.malloc_state*
  %5 = bitcast i8* %oldbase to i64*
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %5) #7
  %7 = bitcast i64* %6 to i8*
  %8 = bitcast i8* %newbase to i64*
  %9 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %8) #7
  %10 = bitcast i64* %9 to i8*
  %add.ptr = getelementptr inbounds i8, i8* %newbase, i64 16
  %11 = ptrtoint i8* %add.ptr to i64
  %and = and i64 %11, 15
  %cmp = icmp eq i64 %and, 0
  %sub = sub i64 0, %11
  %and3 = and i64 %sub, 15
  %cond = select i1 %cmp, i64 0, i64 %and3
  %add.ptr4 = getelementptr inbounds i8, i8* %newbase, i64 %cond
  %12 = getelementptr inbounds i8, i8* %10, i64 %cond
  %add.ptr5 = getelementptr inbounds i8, i8* %oldbase, i64 16
  %13 = ptrtoint i8* %add.ptr5 to i64
  %and6 = and i64 %13, 15
  %cmp7 = icmp eq i64 %and6, 0
  %sub12 = sub i64 0, %13
  %and13 = and i64 %sub12, 15
  %cond15 = select i1 %cmp7, i64 0, i64 %and13
  %add.ptr16 = getelementptr inbounds i8, i8* %oldbase, i64 %cond15
  %14 = getelementptr inbounds i8, i8* %7, i64 %cond15
  %15 = bitcast i8* %add.ptr16 to %struct.malloc_chunk*
  %sub.ptr.lhs.cast = ptrtoint i8* %add.ptr16 to i64
  %sub.ptr.rhs.cast = ptrtoint i8* %add.ptr4 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %add.ptr17 = getelementptr inbounds i8, i8* %add.ptr4, i64 %nb
  %16 = getelementptr inbounds i8, i8* %12, i64 %nb
  %sub18 = sub i64 %sub.ptr.sub, %nb
  %or19 = or i64 %nb, 3
  %17 = getelementptr inbounds i8, i8* %12, i64 8
  %18 = bitcast i8* %17 to i64*
  store i64 %or19, i64* %18, align 8, !tbaa !11
  %19 = getelementptr inbounds i64, i64* %3, i64 5
  %20 = bitcast i64* %19 to %struct.malloc_chunk**
  %21 = load %struct.malloc_chunk*, %struct.malloc_chunk** %20, align 8, !tbaa !37
  %cmp20 = icmp eq %struct.malloc_chunk* %21, %15
  br i1 %cmp20, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %22 = getelementptr inbounds i64, i64* %3, i64 2
  %23 = load i64, i64* %22, align 8, !tbaa !36
  %add = add i64 %23, %sub18
  store i64 %add, i64* %22, align 8, !tbaa !36
  %24 = bitcast i64* %19 to i8**
  store i8* %add.ptr17, i8** %24, align 8, !tbaa !37
  %or22 = or i64 %add, 1
  %25 = getelementptr inbounds i8, i8* %16, i64 8
  %26 = bitcast i8* %25 to i64*
  store i64 %or22, i64* %26, align 8, !tbaa !11
  br label %if.end388

if.else:                                          ; preds = %entry
  %27 = getelementptr inbounds i64, i64* %3, i64 4
  %28 = bitcast i64* %27 to %struct.malloc_chunk**
  %29 = load %struct.malloc_chunk*, %struct.malloc_chunk** %28, align 8, !tbaa !33
  %cmp24 = icmp eq %struct.malloc_chunk* %29, %15
  br i1 %cmp24, label %if.then25, label %if.else31

if.then25:                                        ; preds = %if.else
  %30 = getelementptr inbounds i64, i64* %3, i64 1
  %31 = load i64, i64* %30, align 8, !tbaa !31
  %add26 = add i64 %31, %sub18
  store i64 %add26, i64* %30, align 8, !tbaa !31
  %32 = bitcast i64* %27 to i8**
  store i8* %add.ptr17, i8** %32, align 8, !tbaa !33
  %or28 = or i64 %add26, 1
  %33 = getelementptr inbounds i8, i8* %16, i64 8
  %34 = bitcast i8* %33 to i64*
  store i64 %or28, i64* %34, align 8, !tbaa !11
  %35 = getelementptr inbounds i8, i8* %16, i64 %add26
  %36 = bitcast i8* %35 to i64*
  store i64 %add26, i64* %36, align 8, !tbaa !32
  br label %if.end388

if.else31:                                        ; preds = %if.else
  %37 = getelementptr inbounds i8, i8* %14, i64 8
  %38 = bitcast i8* %37 to i64*
  %39 = load i64, i64* %38, align 8, !tbaa !11
  %and33 = and i64 %39, 3
  %cmp34 = icmp eq i64 %and33, 1
  br i1 %cmp34, label %if.then35, label %if.end233

if.then35:                                        ; preds = %if.else31
  %and37 = and i64 %39, -8
  %cmp38 = icmp ult i64 %39, 256
  br i1 %cmp38, label %if.then39, label %if.else83

if.then39:                                        ; preds = %if.then35
  %shr = lshr i64 %39, 3
  %40 = getelementptr inbounds i8, i8* %14, i64 16
  %41 = bitcast i8* %40 to %struct.malloc_chunk**
  %42 = load %struct.malloc_chunk*, %struct.malloc_chunk** %41, align 8, !tbaa !28
  %43 = getelementptr inbounds i8, i8* %14, i64 24
  %44 = bitcast i8* %43 to %struct.malloc_chunk**
  %45 = load %struct.malloc_chunk*, %struct.malloc_chunk** %44, align 8, !tbaa !29
  %conv = trunc i64 %shr to i32
  %shl601 = shl nuw nsw i64 %shr, 1
  %idxprom = and i64 %shl601, 4294967294
  %arrayidx = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom
  %46 = bitcast %struct.malloc_chunk** %arrayidx to %struct.malloc_chunk*
  %cmp41 = icmp eq %struct.malloc_chunk* %42, %46
  %47 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %42, i64 0, i32 0
  %48 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %47) #7
  %49 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %45, i64 0, i32 0
  %50 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %49) #7
  br i1 %cmp41, label %if.then49, label %lor.rhs

lor.rhs:                                          ; preds = %if.then39
  %51 = bitcast %struct.malloc_chunk* %42 to i8*
  %52 = getelementptr inbounds i64, i64* %3, i64 3
  %53 = bitcast i64* %52 to i8**
  %54 = load i8*, i8** %53, align 8, !tbaa !14
  %cmp43 = icmp ugt i8* %54, %51
  br i1 %cmp43, label %if.else81, label %land.rhs

land.rhs:                                         ; preds = %lor.rhs
  %55 = getelementptr inbounds i64, i64* %48, i64 3
  %56 = bitcast i64* %55 to %struct.malloc_chunk**
  %57 = load %struct.malloc_chunk*, %struct.malloc_chunk** %56, align 8, !tbaa !29
  %cmp46 = icmp eq %struct.malloc_chunk* %57, %15
  br i1 %cmp46, label %if.then49, label %if.else81, !prof !30

if.then49:                                        ; preds = %if.then39, %land.rhs
  %cmp50 = icmp eq %struct.malloc_chunk* %45, %42
  br i1 %cmp50, label %if.then52, label %if.else55

if.then52:                                        ; preds = %if.then49
  %shl53 = shl i32 1, %conv
  %neg = xor i32 %shl53, -1
  %58 = bitcast i64* %3 to i32*
  %59 = load i32, i32* %58, align 8, !tbaa !27
  %and54 = and i32 %59, %neg
  store i32 %and54, i32* %58, align 8, !tbaa !27
  br label %if.end230

if.else55:                                        ; preds = %if.then49
  %cmp60 = icmp eq %struct.malloc_chunk* %45, %46
  br i1 %cmp60, label %if.else55.if.then76_crit_edge, label %lor.rhs62

if.else55.if.then76_crit_edge:                    ; preds = %if.else55
  %.pre615 = getelementptr inbounds i64, i64* %50, i64 2
  %.pre617 = bitcast i64* %.pre615 to %struct.malloc_chunk**
  br label %if.then76

lor.rhs62:                                        ; preds = %if.else55
  %60 = bitcast %struct.malloc_chunk* %45 to i8*
  %61 = getelementptr inbounds i64, i64* %3, i64 3
  %62 = bitcast i64* %61 to i8**
  %63 = load i8*, i8** %62, align 8, !tbaa !14
  %cmp64 = icmp ugt i8* %63, %60
  br i1 %cmp64, label %if.else79, label %land.rhs66

land.rhs66:                                       ; preds = %lor.rhs62
  %64 = getelementptr inbounds i64, i64* %50, i64 2
  %65 = bitcast i64* %64 to %struct.malloc_chunk**
  %66 = load %struct.malloc_chunk*, %struct.malloc_chunk** %65, align 8, !tbaa !28
  %cmp68 = icmp eq %struct.malloc_chunk* %66, %15
  br i1 %cmp68, label %if.then76, label %if.else79, !prof !30

if.then76:                                        ; preds = %if.else55.if.then76_crit_edge, %land.rhs66
  %.pre-phi618 = phi %struct.malloc_chunk** [ %.pre617, %if.else55.if.then76_crit_edge ], [ %65, %land.rhs66 ]
  %67 = getelementptr inbounds i64, i64* %48, i64 3
  %68 = bitcast i64* %67 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %45, %struct.malloc_chunk** %68, align 8, !tbaa !29
  store %struct.malloc_chunk* %42, %struct.malloc_chunk** %.pre-phi618, align 8, !tbaa !28
  br label %if.end230

if.else79:                                        ; preds = %lor.rhs62, %land.rhs66
  tail call void %1() #8
  unreachable

if.else81:                                        ; preds = %lor.rhs, %land.rhs
  tail call void %1() #8
  unreachable

if.else83:                                        ; preds = %if.then35
  %69 = bitcast i8* %add.ptr16 to %struct.malloc_tree_chunk*
  %70 = getelementptr inbounds i8, i8* %14, i64 48
  %71 = bitcast i8* %70 to %struct.malloc_tree_chunk**
  %72 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %71, align 8, !tbaa !41
  %73 = getelementptr inbounds i8, i8* %14, i64 24
  %74 = bitcast i8* %73 to %struct.malloc_tree_chunk**
  %75 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %74, align 8, !tbaa !42
  %cmp85 = icmp eq %struct.malloc_tree_chunk* %75, %69
  %76 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %72, i64 0, i32 0
  %77 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %76) #7
  %78 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %75, i64 0, i32 0
  %79 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %78) #7
  br i1 %cmp85, label %if.else110, label %if.then87

if.then87:                                        ; preds = %if.else83
  %80 = getelementptr inbounds i8, i8* %14, i64 16
  %81 = bitcast i8* %80 to %struct.malloc_tree_chunk**
  %82 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %81, align 8, !tbaa !43
  %83 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %82, i64 0, i32 0
  %84 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %83) #7
  %85 = bitcast %struct.malloc_tree_chunk* %82 to i8*
  %86 = getelementptr inbounds i64, i64* %3, i64 3
  %87 = bitcast i64* %86 to i8**
  %88 = load i8*, i8** %87, align 8, !tbaa !14
  %cmp92 = icmp ugt i8* %88, %85
  br i1 %cmp92, label %if.else108, label %land.lhs.true

land.lhs.true:                                    ; preds = %if.then87
  %89 = getelementptr inbounds i64, i64* %84, i64 3
  %90 = bitcast i64* %89 to %struct.malloc_tree_chunk**
  %91 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %90, align 8, !tbaa !42
  %cmp95 = icmp eq %struct.malloc_tree_chunk* %91, %69
  br i1 %cmp95, label %land.rhs97, label %if.else108

land.rhs97:                                       ; preds = %land.lhs.true
  %92 = getelementptr inbounds i64, i64* %79, i64 2
  %93 = bitcast i64* %92 to %struct.malloc_tree_chunk**
  %94 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %93, align 8, !tbaa !43
  %cmp99 = icmp eq %struct.malloc_tree_chunk* %94, %69
  br i1 %cmp99, label %if.then105, label %if.else108, !prof !30

if.then105:                                       ; preds = %land.rhs97
  store %struct.malloc_tree_chunk* %75, %struct.malloc_tree_chunk** %90, align 8, !tbaa !42
  store %struct.malloc_tree_chunk* %82, %struct.malloc_tree_chunk** %93, align 8, !tbaa !43
  br label %if.end140

if.else108:                                       ; preds = %if.then87, %land.lhs.true, %land.rhs97
  tail call void %1() #8
  unreachable

if.else110:                                       ; preds = %if.else83
  %child = getelementptr inbounds i8, i8* %add.ptr16, i64 32
  %95 = getelementptr inbounds i8, i8* %14, i64 32
  %arrayidx111 = getelementptr inbounds i8, i8* %child, i64 8
  %96 = getelementptr inbounds i8, i8* %95, i64 8
  %97 = bitcast i8* %96 to %struct.malloc_tree_chunk**
  %98 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %97, align 8, !tbaa !38
  %cmp112 = icmp eq %struct.malloc_tree_chunk* %98, null
  %99 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %98, i64 0, i32 0
  %100 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %99) #7
  %101 = bitcast i64* %100 to %struct.malloc_tree_chunk*
  br i1 %cmp112, label %lor.lhs.false, label %if.then118

lor.lhs.false:                                    ; preds = %if.else110
  %102 = bitcast i8* %95 to %struct.malloc_tree_chunk**
  %103 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %102, align 8, !tbaa !38
  %cmp116 = icmp eq %struct.malloc_tree_chunk* %103, null
  %104 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %103, i64 0, i32 0
  %105 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %104) #7
  %106 = bitcast i64* %105 to %struct.malloc_tree_chunk*
  br i1 %cmp116, label %if.end140, label %if.then118

if.then118:                                       ; preds = %lor.lhs.false, %if.else110
  %RP.0.in = phi i8* [ %arrayidx111, %if.else110 ], [ %child, %lor.lhs.false ]
  %107 = phi %struct.malloc_tree_chunk** [ %97, %if.else110 ], [ %102, %lor.lhs.false ]
  %R.0 = phi %struct.malloc_tree_chunk* [ %98, %if.else110 ], [ %103, %lor.lhs.false ]
  %108 = phi %struct.malloc_tree_chunk* [ %101, %if.else110 ], [ %106, %lor.lhs.false ]
  %RP.0 = bitcast i8* %RP.0.in to %struct.malloc_tree_chunk**
  br label %while.cond

while.cond:                                       ; preds = %while.body, %if.then118
  %RP.1 = phi %struct.malloc_tree_chunk** [ %RP.0, %if.then118 ], [ %CP.0, %while.body ]
  %109 = phi %struct.malloc_tree_chunk** [ %107, %if.then118 ], [ %CP.0, %while.body ]
  %R.1 = phi %struct.malloc_tree_chunk* [ %R.0, %if.then118 ], [ %115, %while.body ]
  %110 = phi %struct.malloc_tree_chunk* [ %108, %if.then118 ], [ %115, %while.body ]
  %arrayidx120 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 1
  %111 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %110, i64 0, i32 4, i64 1
  %112 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %111, align 8, !tbaa !38
  %cmp121 = icmp eq %struct.malloc_tree_chunk* %112, null
  br i1 %cmp121, label %lor.rhs123, label %while.body

lor.rhs123:                                       ; preds = %while.cond
  %arrayidx125 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 0
  %113 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %110, i64 0, i32 4, i64 0
  %114 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %113, align 8, !tbaa !38
  %cmp126 = icmp eq %struct.malloc_tree_chunk* %114, null
  br i1 %cmp126, label %while.end, label %while.body

while.body:                                       ; preds = %lor.rhs123, %while.cond
  %115 = phi %struct.malloc_tree_chunk* [ %112, %while.cond ], [ %114, %lor.rhs123 ]
  %CP.0 = phi %struct.malloc_tree_chunk** [ %arrayidx120, %while.cond ], [ %arrayidx125, %lor.rhs123 ]
  %116 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %115, i64 0, i32 0
  %117 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %116) #7
  br label %while.cond

while.end:                                        ; preds = %lor.rhs123
  %118 = bitcast %struct.malloc_tree_chunk** %RP.1 to i8*
  %119 = getelementptr inbounds i64, i64* %3, i64 3
  %120 = bitcast i64* %119 to i8**
  %121 = load i8*, i8** %120, align 8, !tbaa !14
  %cmp131 = icmp ugt i8* %121, %118
  br i1 %cmp131, label %if.else137, label %if.then136, !prof !34

if.then136:                                       ; preds = %while.end
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %109, align 8, !tbaa !38
  br label %if.end140

if.else137:                                       ; preds = %while.end
  tail call void %1() #8
  unreachable

if.end140:                                        ; preds = %if.then136, %lor.lhs.false, %if.then105
  %R.3 = phi %struct.malloc_tree_chunk* [ %75, %if.then105 ], [ %R.1, %if.then136 ], [ null, %lor.lhs.false ]
  %122 = phi %struct.malloc_tree_chunk* [ %75, %if.then105 ], [ %R.1, %if.then136 ], [ %106, %lor.lhs.false ]
  %cmp141 = icmp eq %struct.malloc_tree_chunk* %72, null
  br i1 %cmp141, label %if.end230, label %if.then143

if.then143:                                       ; preds = %if.end140
  %123 = getelementptr inbounds i64, i64* %3, i64 75
  %124 = bitcast i64* %123 to [32 x %struct.malloc_tree_chunk*]*
  %125 = getelementptr inbounds i8, i8* %14, i64 56
  %126 = bitcast i8* %125 to i32*
  %127 = load i32, i32* %126, align 8, !tbaa !44
  %idxprom144 = zext i32 %127 to i64
  %128 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %124, i64 0, i64 %idxprom144
  %129 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %128, align 8, !tbaa !38
  %cmp146 = icmp eq %struct.malloc_tree_chunk* %129, %69
  br i1 %cmp146, label %if.then148, label %if.else157

if.then148:                                       ; preds = %if.then143
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %128, align 8, !tbaa !38
  %cond604 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cond604, label %if.end178.thread, label %if.then181

if.end178.thread:                                 ; preds = %if.then148
  %shl153 = shl i32 1, %127
  %neg154 = xor i32 %shl153, -1
  %130 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %4, i64 0, i32 1
  %131 = load i32, i32* %130, align 4, !tbaa !35
  %and155 = and i32 %131, %neg154
  store i32 %and155, i32* %130, align 4, !tbaa !35
  br label %if.end230

if.else157:                                       ; preds = %if.then143
  %132 = bitcast %struct.malloc_tree_chunk* %72 to i8*
  %133 = getelementptr inbounds i64, i64* %3, i64 3
  %134 = bitcast i64* %133 to i8**
  %135 = load i8*, i8** %134, align 8, !tbaa !14
  %cmp159 = icmp ugt i8* %135, %132
  br i1 %cmp159, label %if.else176, label %if.end178, !prof !34

if.else176:                                       ; preds = %if.else157
  tail call void %1() #8
  unreachable

if.end178:                                        ; preds = %if.else157
  %136 = getelementptr inbounds i64, i64* %77, i64 4
  %137 = bitcast i64* %136 to [2 x %struct.malloc_tree_chunk*]*
  %138 = bitcast i64* %136 to %struct.malloc_tree_chunk**
  %139 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %138, align 8, !tbaa !38
  %cmp167 = icmp ne %struct.malloc_tree_chunk* %139, %69
  %.sink = zext i1 %cmp167 to i64
  %140 = getelementptr inbounds [2 x %struct.malloc_tree_chunk*], [2 x %struct.malloc_tree_chunk*]* %137, i64 0, i64 %.sink
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %140, align 8, !tbaa !38
  %cmp179 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cmp179, label %if.end230, label %if.then181

if.then181:                                       ; preds = %if.then148, %if.end178
  %141 = bitcast %struct.malloc_tree_chunk* %R.3 to i8*
  %142 = getelementptr inbounds i64, i64* %3, i64 3
  %143 = bitcast i64* %142 to i8**
  %144 = load i8*, i8** %143, align 8, !tbaa !14
  %cmp183 = icmp ugt i8* %144, %141
  br i1 %cmp183, label %if.else226, label %if.then188, !prof !34

if.then188:                                       ; preds = %if.then181
  %145 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %122, i64 0, i32 5
  store %struct.malloc_tree_chunk* %72, %struct.malloc_tree_chunk** %145, align 8, !tbaa !41
  %146 = getelementptr inbounds i8, i8* %14, i64 32
  %147 = bitcast i8* %146 to %struct.malloc_tree_chunk**
  %148 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %147, align 8, !tbaa !38
  %cmp192 = icmp eq %struct.malloc_tree_chunk* %148, null
  %149 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %148, i64 0, i32 0
  %150 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %149) #7
  br i1 %cmp192, label %if.end207, label %if.then194

if.then194:                                       ; preds = %if.then188
  %151 = bitcast %struct.malloc_tree_chunk* %148 to i8*
  %152 = load i8*, i8** %143, align 8, !tbaa !14
  %cmp196 = icmp ugt i8* %152, %151
  br i1 %cmp196, label %if.else205, label %if.then201, !prof !34

if.then201:                                       ; preds = %if.then194
  %153 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %122, i64 0, i32 4, i64 0
  store %struct.malloc_tree_chunk* %148, %struct.malloc_tree_chunk** %153, align 8, !tbaa !38
  %154 = getelementptr inbounds i64, i64* %150, i64 6
  %155 = bitcast i64* %154 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %155, align 8, !tbaa !41
  br label %if.end207

if.else205:                                       ; preds = %if.then194
  tail call void %1() #8
  unreachable

if.end207:                                        ; preds = %if.then188, %if.then201
  %156 = getelementptr inbounds i8, i8* %146, i64 8
  %157 = bitcast i8* %156 to %struct.malloc_tree_chunk**
  %158 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %157, align 8, !tbaa !38
  %cmp210 = icmp eq %struct.malloc_tree_chunk* %158, null
  %159 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %158, i64 0, i32 0
  %160 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %159) #7
  br i1 %cmp210, label %if.end230, label %if.then212

if.then212:                                       ; preds = %if.end207
  %161 = bitcast %struct.malloc_tree_chunk* %158 to i8*
  %162 = load i8*, i8** %143, align 8, !tbaa !14
  %cmp214 = icmp ugt i8* %162, %161
  br i1 %cmp214, label %if.else223, label %if.then219, !prof !34

if.then219:                                       ; preds = %if.then212
  %163 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %122, i64 0, i32 4, i64 1
  store %struct.malloc_tree_chunk* %158, %struct.malloc_tree_chunk** %163, align 8, !tbaa !38
  %164 = getelementptr inbounds i64, i64* %160, i64 6
  %165 = bitcast i64* %164 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %165, align 8, !tbaa !41
  br label %if.end230

if.else223:                                       ; preds = %if.then212
  tail call void %1() #8
  unreachable

if.else226:                                       ; preds = %if.then181
  tail call void %1() #8
  unreachable

if.end230:                                        ; preds = %if.end178.thread, %if.end140, %if.then219, %if.end207, %if.end178, %if.then76, %if.then52
  %166 = getelementptr inbounds i8, i8* %14, i64 %and37
  %add232 = add i64 %and37, %sub18
  %.phi.trans.insert = getelementptr inbounds i8, i8* %166, i64 8
  %.phi.trans.insert613 = bitcast i8* %.phi.trans.insert to i64*
  %.pre = load i64, i64* %.phi.trans.insert613, align 8, !tbaa !11
  br label %if.end233

if.end233:                                        ; preds = %if.else31, %if.end230
  %167 = phi i64 [ %39, %if.else31 ], [ %.pre, %if.end230 ]
  %qsize.0 = phi i64 [ %sub18, %if.else31 ], [ %add232, %if.end230 ]
  %.in = phi i8* [ %14, %if.else31 ], [ %166, %if.end230 ]
  %168 = getelementptr inbounds i8, i8* %.in, i64 8
  %169 = bitcast i8* %168 to i64*
  %and235 = and i64 %167, -2
  store i64 %and235, i64* %169, align 8, !tbaa !11
  %or236 = or i64 %qsize.0, 1
  %170 = getelementptr inbounds i8, i8* %16, i64 8
  %171 = bitcast i8* %170 to i64*
  store i64 %or236, i64* %171, align 8, !tbaa !11
  %172 = getelementptr inbounds i8, i8* %16, i64 %qsize.0
  %173 = bitcast i8* %172 to i64*
  store i64 %qsize.0, i64* %173, align 8, !tbaa !32
  %cmp241 = icmp ult i64 %qsize.0, 256
  br i1 %cmp241, label %if.then243, label %if.else278

if.then243:                                       ; preds = %if.end233
  %shr240 = lshr i64 %qsize.0, 3
  %conv246 = trunc i64 %shr240 to i32
  %174 = getelementptr inbounds i64, i64* %3, i64 9
  %175 = bitcast i64* %174 to [66 x %struct.malloc_chunk*]*
  %shl249599 = shl nuw nsw i64 %shr240, 1
  %idxprom250 = and i64 %shl249599, 4294967294
  %arrayidx251 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom250
  %176 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %175, i64 0, i64 %idxprom250
  %177 = bitcast i64* %3 to i32*
  %178 = load i32, i32* %177, align 8, !tbaa !27
  %shl254 = shl i32 1, %conv246
  %and255 = and i32 %178, %shl254
  %tobool256 = icmp eq i32 %and255, 0
  br i1 %tobool256, label %if.then257, label %if.else261

if.then257:                                       ; preds = %if.then243
  %179 = bitcast %struct.malloc_chunk** %176 to %struct.malloc_chunk*
  %180 = bitcast %struct.malloc_chunk** %arrayidx251 to %struct.malloc_chunk*
  %or260 = or i32 %178, %shl254
  store i32 %or260, i32* %177, align 8, !tbaa !27
  %.pre614 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %176, i64 2
  br label %if.end273

if.else261:                                       ; preds = %if.then243
  %181 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %176, i64 2
  %182 = load %struct.malloc_chunk*, %struct.malloc_chunk** %181, align 8, !tbaa !28
  %183 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %182, i64 0, i32 0
  %184 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %183) #7
  %185 = bitcast %struct.malloc_chunk* %182 to i8*
  %186 = getelementptr inbounds i64, i64* %3, i64 3
  %187 = bitcast i64* %186 to i8**
  %188 = load i8*, i8** %187, align 8, !tbaa !14
  %cmp264 = icmp ugt i8* %188, %185
  br i1 %cmp264, label %if.else271, label %if.end273, !prof !34

if.else271:                                       ; preds = %if.else261
  tail call void %1() #8
  unreachable

if.end273:                                        ; preds = %if.else261, %if.then257
  %.pre-phi = phi %struct.malloc_chunk** [ %181, %if.else261 ], [ %.pre614, %if.then257 ]
  %F252.0 = phi %struct.malloc_chunk* [ %182, %if.else261 ], [ %180, %if.then257 ]
  %189 = phi %struct.malloc_chunk* [ %182, %if.else261 ], [ %179, %if.then257 ]
  %190 = bitcast %struct.malloc_chunk** %.pre-phi to i8**
  store i8* %add.ptr17, i8** %190, align 8, !tbaa !28
  %191 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %189, i64 0, i32 3
  %192 = bitcast %struct.malloc_chunk** %191 to i8**
  store i8* %add.ptr17, i8** %192, align 8, !tbaa !29
  %193 = getelementptr inbounds i8, i8* %16, i64 16
  %194 = bitcast i8* %193 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %F252.0, %struct.malloc_chunk** %194, align 8, !tbaa !28
  %195 = getelementptr inbounds i8, i8* %16, i64 24
  %196 = bitcast i8* %195 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx251, %struct.malloc_chunk*** %196, align 8, !tbaa !29
  br label %if.end388

if.else278:                                       ; preds = %if.end233
  %shr282 = lshr i64 %qsize.0, 8
  %conv283 = trunc i64 %shr282 to i32
  %cmp284 = icmp eq i32 %conv283, 0
  br i1 %cmp284, label %if.end301, label %if.else287

if.else287:                                       ; preds = %if.else278
  %cmp288 = icmp ugt i32 %conv283, 65535
  br i1 %cmp288, label %if.end301, label %if.else291

if.else291:                                       ; preds = %if.else287
  %197 = tail call i32 @llvm.ctlz.i32(i32 %conv283, i1 true)
  %sub292 = xor i32 %197, 31
  %shl293 = shl nuw nsw i32 %sub292, 1
  %conv294 = zext i32 %shl293 to i64
  %add295 = add nuw nsw i32 %sub292, 7
  %sh_prom = zext i32 %add295 to i64
  %shr296 = lshr i64 %qsize.0, %sh_prom
  %and297 = and i64 %shr296, 1
  %add298 = or i64 %and297, %conv294
  %conv299 = trunc i64 %add298 to i32
  br label %if.end301

if.end301:                                        ; preds = %if.else287, %if.else278, %if.else291
  %I281.0 = phi i32 [ %conv299, %if.else291 ], [ 0, %if.else278 ], [ 31, %if.else287 ]
  %198 = getelementptr inbounds i64, i64* %3, i64 75
  %199 = bitcast i64* %198 to [32 x %struct.malloc_tree_chunk*]*
  %idxprom303 = zext i32 %I281.0 to i64
  %200 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %199, i64 0, i64 %idxprom303
  %201 = getelementptr inbounds i8, i8* %16, i64 56
  %202 = bitcast i8* %201 to i32*
  store i32 %I281.0, i32* %202, align 8, !tbaa !44
  %203 = getelementptr inbounds i8, i8* %16, i64 32
  %204 = bitcast i8* %203 to <2 x %struct.malloc_tree_chunk*>*
  store <2 x %struct.malloc_tree_chunk*> zeroinitializer, <2 x %struct.malloc_tree_chunk*>* %204, align 8, !tbaa !38
  %205 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %4, i64 0, i32 1
  %206 = load i32, i32* %205, align 4, !tbaa !35
  %shl311 = shl i32 1, %I281.0
  %and312 = and i32 %206, %shl311
  %tobool313 = icmp eq i32 %and312, 0
  br i1 %tobool313, label %if.then314, label %if.else321

if.then314:                                       ; preds = %if.end301
  %arrayidx304 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 11, i64 %idxprom303
  %or317 = or i32 %206, %shl311
  store i32 %or317, i32* %205, align 4, !tbaa !35
  %207 = bitcast %struct.malloc_tree_chunk** %200 to i8**
  store i8* %add.ptr17, i8** %207, align 8, !tbaa !38
  %208 = getelementptr inbounds i8, i8* %16, i64 48
  %209 = bitcast i8* %208 to %struct.malloc_tree_chunk***
  store %struct.malloc_tree_chunk** %arrayidx304, %struct.malloc_tree_chunk*** %209, align 8, !tbaa !41
  %210 = getelementptr inbounds i8, i8* %16, i64 24
  %211 = bitcast i8* %210 to i8**
  store i8* %add.ptr17, i8** %211, align 8, !tbaa !42
  %212 = getelementptr inbounds i8, i8* %16, i64 16
  %213 = bitcast i8* %212 to i8**
  store i8* %add.ptr17, i8** %213, align 8, !tbaa !43
  br label %if.end388

if.else321:                                       ; preds = %if.end301
  %214 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %200, align 8, !tbaa !38
  %cmp323 = icmp eq i32 %I281.0, 31
  %215 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %214, i64 0, i32 0
  %216 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %215) #7
  %217 = bitcast i64* %216 to %struct.malloc_tree_chunk*
  br i1 %cmp323, label %cond.end332, label %cond.false326

cond.false326:                                    ; preds = %if.else321
  %shr327 = lshr i32 %I281.0, 1
  %sub329 = add nuw i32 %shr327, 6
  %conv330 = zext i32 %sub329 to i64
  %sub331 = sub nsw i64 63, %conv330
  br label %cond.end332

cond.end332:                                      ; preds = %if.else321, %cond.false326
  %cond333 = phi i64 [ %sub331, %cond.false326 ], [ 0, %if.else321 ]
  %shl334 = shl i64 %qsize.0, %cond333
  br label %for.cond

for.cond:                                         ; preds = %if.then339, %cond.end332
  %T.0 = phi %struct.malloc_tree_chunk* [ %214, %cond.end332 ], [ %222, %if.then339 ]
  %218 = phi %struct.malloc_tree_chunk* [ %217, %cond.end332 ], [ %222, %if.then339 ]
  %K322.0 = phi i64 [ %shl334, %cond.end332 ], [ %shl344, %if.then339 ]
  %219 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %218, i64 0, i32 1
  %220 = load i64, i64* %219, align 8, !tbaa !39
  %and336 = and i64 %220, -8
  %cmp337 = icmp eq i64 %and336, %qsize.0
  br i1 %cmp337, label %if.else361, label %if.then339

if.then339:                                       ; preds = %for.cond
  %shr341 = lshr i64 %K322.0, 63
  %221 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %218, i64 0, i32 4, i64 %shr341
  %shl344 = shl i64 %K322.0, 1
  %222 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %221, align 8, !tbaa !38
  %cmp345 = icmp eq %struct.malloc_tree_chunk* %222, null
  %223 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %222, i64 0, i32 0
  %224 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %223) #7
  br i1 %cmp345, label %if.else348, label %for.cond

if.else348:                                       ; preds = %if.then339
  %arrayidx343 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %T.0, i64 0, i32 4, i64 %shr341
  %225 = bitcast %struct.malloc_tree_chunk** %arrayidx343 to i8*
  %226 = getelementptr inbounds i64, i64* %3, i64 3
  %227 = bitcast i64* %226 to i8**
  %228 = load i8*, i8** %227, align 8, !tbaa !14
  %cmp350 = icmp ugt i8* %228, %225
  br i1 %cmp350, label %if.else359, label %cleanup, !prof !34

if.else359:                                       ; preds = %if.else348
  tail call void %1() #8
  unreachable

cleanup:                                          ; preds = %if.else348
  %229 = bitcast %struct.malloc_tree_chunk** %221 to i8**
  store i8* %add.ptr17, i8** %229, align 8, !tbaa !38
  %230 = getelementptr inbounds i8, i8* %16, i64 48
  %231 = bitcast i8* %230 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %231, align 8, !tbaa !41
  %232 = getelementptr inbounds i8, i8* %16, i64 24
  %233 = bitcast i8* %232 to i8**
  store i8* %add.ptr17, i8** %233, align 8, !tbaa !42
  %234 = getelementptr inbounds i8, i8* %16, i64 16
  %235 = bitcast i8* %234 to i8**
  store i8* %add.ptr17, i8** %235, align 8, !tbaa !43
  br label %if.end388

if.else361:                                       ; preds = %for.cond
  %236 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %218, i64 0, i32 2
  %237 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %236, align 8, !tbaa !43
  %238 = bitcast %struct.malloc_tree_chunk* %T.0 to i8*
  %239 = getelementptr inbounds i64, i64* %3, i64 3
  %240 = bitcast i64* %239 to i8**
  %241 = load i8*, i8** %240, align 8, !tbaa !14
  %cmp365 = icmp ule i8* %241, %238
  %242 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %237, i64 0, i32 0
  %243 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %242) #7
  %244 = bitcast %struct.malloc_tree_chunk* %237 to i8*
  %cmp369 = icmp ule i8* %241, %244
  %245 = and i1 %cmp369, %cmp365
  br i1 %245, label %if.then376, label %if.else382, !prof !30

if.then376:                                       ; preds = %if.else361
  %246 = getelementptr inbounds i64, i64* %243, i64 3
  %247 = bitcast i64* %246 to i8**
  store i8* %add.ptr17, i8** %247, align 8, !tbaa !42
  %248 = bitcast %struct.malloc_tree_chunk** %236 to i8**
  store i8* %add.ptr17, i8** %248, align 8, !tbaa !43
  %249 = getelementptr inbounds i8, i8* %16, i64 16
  %250 = bitcast i8* %249 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %237, %struct.malloc_tree_chunk** %250, align 8, !tbaa !43
  %251 = getelementptr inbounds i8, i8* %16, i64 24
  %252 = bitcast i8* %251 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %252, align 8, !tbaa !42
  %253 = getelementptr inbounds i8, i8* %16, i64 48
  %254 = bitcast i8* %253 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %254, align 8, !tbaa !41
  br label %if.end388

if.else382:                                       ; preds = %if.else361
  tail call void %1() #8
  unreachable

if.end388:                                        ; preds = %cleanup, %if.then314, %if.then376, %if.then25, %if.end273, %if.then
  %add.ptr389 = getelementptr inbounds i8, i8* %add.ptr4, i64 16
  ret i8* %add.ptr389
}

; Function Attrs: nounwind uwtable
define internal void @add_segment(%struct.malloc_state* %m, i8* %tbase, i64 %tsize, i32 %mmapped) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void (%struct.malloc_state*, %struct.malloc_chunk*, i64)* @init_top to i64*)) #7
  %2 = bitcast i64* %1 to void (%struct.malloc_state*, %struct.malloc_chunk*, i64)*
  %3 = bitcast i8* %tbase to i64*
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %3) #7
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (%struct.malloc_segment* (%struct.malloc_state*, i8*)* @segment_holding to i64*)) #7
  %6 = bitcast i64* %5 to %struct.malloc_segment* (%struct.malloc_state*, i8*)*
  %7 = bitcast %struct.malloc_state* %m to i64*
  %8 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %7) #7
  %9 = getelementptr inbounds i64, i64* %8, i64 5
  %10 = bitcast i64* %9 to %struct.malloc_chunk**
  %11 = load %struct.malloc_chunk*, %struct.malloc_chunk** %10, align 8, !tbaa !37
  %12 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %11, i64 0, i32 0
  %13 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %12) #7
  %14 = bitcast %struct.malloc_chunk* %11 to i8*
  %15 = bitcast i64* %13 to i8*
  %call = tail call %struct.malloc_segment* %6(%struct.malloc_state* %m, i8* %14) #7
  %16 = bitcast %struct.malloc_segment* %call to i64*
  %17 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %16) #7
  %18 = bitcast i64* %17 to i8**
  %19 = load i8*, i8** %18, align 8, !tbaa !48
  %20 = getelementptr inbounds i64, i64* %17, i64 1
  %21 = load i64, i64* %20, align 8, !tbaa !55
  %22 = bitcast i8* %19 to i64*
  %23 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %22) #7
  %24 = bitcast i64* %23 to i8*
  %add.ptr = getelementptr inbounds i8, i8* %19, i64 %21
  %25 = getelementptr inbounds i8, i8* %24, i64 %21
  %add.ptr2 = getelementptr inbounds i8, i8* %add.ptr, i64 -95
  %26 = getelementptr inbounds i8, i8* %25, i64 -95
  %add.ptr3 = getelementptr inbounds i8, i8* %add.ptr2, i64 16
  %27 = ptrtoint i8* %add.ptr3 to i64
  %and = and i64 %27, 15
  %cmp = icmp eq i64 %and, 0
  %sub = sub i64 0, %27
  %and6 = and i64 %sub, 15
  %cond = select i1 %cmp, i64 0, i64 %and6
  %add.ptr7 = getelementptr inbounds i8, i8* %add.ptr2, i64 %cond
  %28 = getelementptr inbounds i8, i8* %26, i64 %cond
  %add.ptr8292 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %11, i64 1
  %add.ptr8 = bitcast %struct.malloc_chunk* %add.ptr8292 to i8*
  %cmp9 = icmp ult i8* %add.ptr7, %add.ptr8
  %29 = select i1 %cmp9, i8* %15, i8* %28
  %cond13 = select i1 %cmp9, i8* %14, i8* %add.ptr7
  %add.ptr14 = getelementptr inbounds i8, i8* %cond13, i64 16
  %30 = getelementptr inbounds i8, i8* %29, i64 16
  %add.ptr15 = getelementptr inbounds i8, i8* %cond13, i64 48
  %31 = getelementptr inbounds i8, i8* %29, i64 48
  %32 = bitcast i8* %tbase to %struct.malloc_chunk*
  %sub16 = add i64 %tsize, -80
  tail call void %2(%struct.malloc_state* %m, %struct.malloc_chunk* %32, i64 %sub16) #7
  %33 = getelementptr inbounds i8, i8* %29, i64 8
  %34 = bitcast i8* %33 to i64*
  store i64 51, i64* %34, align 8, !tbaa !11
  %35 = getelementptr inbounds i64, i64* %8, i64 111
  %36 = bitcast i64* %35 to i8*
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* %30, i8* %36, i64 32, i32 8, i1 false), !tbaa.struct !57
  %37 = bitcast i64* %35 to i8**
  store i8* %tbase, i8** %37, align 8, !tbaa !17
  %38 = getelementptr inbounds i64, i64* %8, i64 112
  store i64 %tsize, i64* %38, align 8, !tbaa !20
  %39 = getelementptr inbounds i64, i64* %8, i64 114
  %40 = bitcast i64* %39 to i32*
  store i32 %mmapped, i32* %40, align 8, !tbaa !25
  %41 = getelementptr inbounds i64, i64* %8, i64 113
  %42 = bitcast i64* %41 to i8**
  store i8* %add.ptr14, i8** %42, align 8, !tbaa !58
  br label %for.cond

for.cond:                                         ; preds = %for.cond, %entry
  %43 = phi i8* [ %add.ptr15, %entry ], [ %add.ptr24, %for.cond ]
  %.in = phi i8* [ %31, %entry ], [ %add.ptr24, %for.cond ]
  %add.ptr24 = getelementptr inbounds i8, i8* %43, i64 8
  %44 = getelementptr inbounds i8, i8* %.in, i64 8
  %45 = bitcast i8* %44 to i64*
  store i64 11, i64* %45, align 8, !tbaa !11
  %head26 = getelementptr inbounds i8, i8* %43, i64 16
  %cmp27 = icmp ult i8* %head26, %add.ptr
  br i1 %cmp27, label %for.cond, label %for.end

for.end:                                          ; preds = %for.cond
  %46 = bitcast i64* %0 to void ()*
  %47 = bitcast i64* %8 to %struct.malloc_state*
  %cmp28 = icmp eq i8* %cond13, %14
  br i1 %cmp28, label %if.end162, label %if.then29

if.then29:                                        ; preds = %for.end
  %sub.ptr.lhs.cast = ptrtoint i8* %cond13 to i64
  %sub.ptr.rhs.cast = ptrtoint %struct.malloc_chunk* %11 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %48 = load i64, i64* %34, align 8, !tbaa !11
  %and32 = and i64 %48, -2
  store i64 %and32, i64* %34, align 8, !tbaa !11
  %or33 = or i64 %sub.ptr.sub, 1
  %49 = getelementptr inbounds i64, i64* %13, i64 1
  store i64 %or33, i64* %49, align 8, !tbaa !11
  %50 = bitcast i8* %29 to i64*
  store i64 %sub.ptr.sub, i64* %50, align 8, !tbaa !32
  %cmp36 = icmp ult i64 %sub.ptr.sub, 256
  br i1 %cmp36, label %if.then37, label %if.else58

if.then37:                                        ; preds = %if.then29
  %shr = lshr i64 %sub.ptr.sub, 3
  %conv = trunc i64 %shr to i32
  %51 = getelementptr inbounds i64, i64* %8, i64 9
  %52 = bitcast i64* %51 to [66 x %struct.malloc_chunk*]*
  %shl294 = shl nuw nsw i64 %shr, 1
  %idxprom = and i64 %shl294, 4294967294
  %arrayidx = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom
  %53 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %52, i64 0, i64 %idxprom
  %54 = bitcast i64* %8 to i32*
  %55 = load i32, i32* %54, align 8, !tbaa !27
  %shl39 = shl i32 1, %conv
  %and40 = and i32 %55, %shl39
  %tobool = icmp eq i32 %and40, 0
  br i1 %tobool, label %if.then41, label %if.else45

if.then41:                                        ; preds = %if.then37
  %56 = bitcast %struct.malloc_chunk** %53 to %struct.malloc_chunk*
  %57 = bitcast %struct.malloc_chunk** %arrayidx to %struct.malloc_chunk*
  %or44 = or i32 %55, %shl39
  store i32 %or44, i32* %54, align 8, !tbaa !27
  %.pre = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %53, i64 2
  br label %if.end54

if.else45:                                        ; preds = %if.then37
  %58 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %53, i64 2
  %59 = load %struct.malloc_chunk*, %struct.malloc_chunk** %58, align 8, !tbaa !28
  %60 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %59, i64 0, i32 0
  %61 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %60) #7
  %62 = bitcast %struct.malloc_chunk* %59 to i8*
  %63 = getelementptr inbounds i64, i64* %8, i64 3
  %64 = bitcast i64* %63 to i8**
  %65 = load i8*, i8** %64, align 8, !tbaa !14
  %cmp46 = icmp ugt i8* %65, %62
  br i1 %cmp46, label %if.else52, label %if.end54, !prof !34

if.else52:                                        ; preds = %if.else45
  tail call void %46() #8
  unreachable

if.end54:                                         ; preds = %if.else45, %if.then41
  %.pre-phi = phi %struct.malloc_chunk** [ %58, %if.else45 ], [ %.pre, %if.then41 ]
  %F.0 = phi %struct.malloc_chunk* [ %59, %if.else45 ], [ %57, %if.then41 ]
  %66 = phi %struct.malloc_chunk* [ %59, %if.else45 ], [ %56, %if.then41 ]
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %.pre-phi, align 8, !tbaa !28
  %67 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %66, i64 0, i32 3
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %67, align 8, !tbaa !29
  %68 = getelementptr inbounds i64, i64* %13, i64 2
  %69 = bitcast i64* %68 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %F.0, %struct.malloc_chunk** %69, align 8, !tbaa !28
  %70 = getelementptr inbounds i64, i64* %13, i64 3
  %71 = bitcast i64* %70 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx, %struct.malloc_chunk*** %71, align 8, !tbaa !29
  br label %if.end162

if.else58:                                        ; preds = %if.then29
  %shr60 = lshr i64 %sub.ptr.sub, 8
  %conv61 = trunc i64 %shr60 to i32
  %cmp62 = icmp eq i32 %conv61, 0
  br i1 %cmp62, label %if.end79, label %if.else65

if.else65:                                        ; preds = %if.else58
  %cmp66 = icmp ugt i32 %conv61, 65535
  br i1 %cmp66, label %if.end79, label %if.else69

if.else69:                                        ; preds = %if.else65
  %72 = tail call i32 @llvm.ctlz.i32(i32 %conv61, i1 true)
  %sub70 = xor i32 %72, 31
  %shl71 = shl nuw nsw i32 %sub70, 1
  %conv72 = zext i32 %shl71 to i64
  %add73 = add nuw nsw i32 %sub70, 7
  %sh_prom = zext i32 %add73 to i64
  %shr74 = lshr i64 %sub.ptr.sub, %sh_prom
  %and75 = and i64 %shr74, 1
  %add76 = or i64 %and75, %conv72
  %conv77 = trunc i64 %add76 to i32
  br label %if.end79

if.end79:                                         ; preds = %if.else65, %if.else58, %if.else69
  %I59.0 = phi i32 [ %conv77, %if.else69 ], [ 0, %if.else58 ], [ 31, %if.else65 ]
  %73 = getelementptr inbounds i64, i64* %8, i64 75
  %74 = bitcast i64* %73 to [32 x %struct.malloc_tree_chunk*]*
  %idxprom80 = zext i32 %I59.0 to i64
  %75 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %74, i64 0, i64 %idxprom80
  %76 = getelementptr inbounds i64, i64* %13, i64 7
  %77 = bitcast i64* %76 to i32*
  store i32 %I59.0, i32* %77, align 8, !tbaa !44
  %78 = getelementptr inbounds i64, i64* %13, i64 4
  %79 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %47, i64 0, i32 1
  %80 = bitcast i64* %78 to i8*
  call void @llvm.memset.p0i8.i64(i8* %80, i8 0, i64 16, i32 8, i1 false)
  %81 = load i32, i32* %79, align 4, !tbaa !35
  %shl85 = shl i32 1, %I59.0
  %and86 = and i32 %81, %shl85
  %tobool87 = icmp eq i32 %and86, 0
  br i1 %tobool87, label %if.then88, label %if.else94

if.then88:                                        ; preds = %if.end79
  %arrayidx81 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 11, i64 %idxprom80
  %or91 = or i32 %81, %shl85
  store i32 %or91, i32* %79, align 4, !tbaa !35
  %82 = bitcast %struct.malloc_tree_chunk** %75 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %82, align 8, !tbaa !38
  %83 = getelementptr inbounds i64, i64* %13, i64 6
  %84 = bitcast i64* %83 to %struct.malloc_tree_chunk***
  store %struct.malloc_tree_chunk** %arrayidx81, %struct.malloc_tree_chunk*** %84, align 8, !tbaa !41
  %85 = getelementptr inbounds i64, i64* %13, i64 3
  %86 = bitcast i64* %85 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %86, align 8, !tbaa !42
  %87 = getelementptr inbounds i64, i64* %13, i64 2
  %88 = bitcast i64* %87 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %88, align 8, !tbaa !43
  br label %if.end162

if.else94:                                        ; preds = %if.end79
  %89 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %75, align 8, !tbaa !38
  %cmp96 = icmp eq i32 %I59.0, 31
  %90 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %89, i64 0, i32 0
  %91 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %90) #7
  %92 = bitcast i64* %91 to %struct.malloc_tree_chunk*
  br i1 %cmp96, label %cond.end105, label %cond.false99

cond.false99:                                     ; preds = %if.else94
  %shr100 = lshr i32 %I59.0, 1
  %sub102 = add nuw i32 %shr100, 6
  %conv103 = zext i32 %sub102 to i64
  %sub104 = sub nsw i64 63, %conv103
  br label %cond.end105

cond.end105:                                      ; preds = %if.else94, %cond.false99
  %cond106 = phi i64 [ %sub104, %cond.false99 ], [ 0, %if.else94 ]
  %shl107 = shl i64 %sub.ptr.sub, %cond106
  br label %for.cond108

for.cond108:                                      ; preds = %if.then113, %cond.end105
  %T.0 = phi %struct.malloc_tree_chunk* [ %89, %cond.end105 ], [ %97, %if.then113 ]
  %93 = phi %struct.malloc_tree_chunk* [ %92, %cond.end105 ], [ %97, %if.then113 ]
  %K95.0 = phi i64 [ %shl107, %cond.end105 ], [ %shl118, %if.then113 ]
  %94 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %93, i64 0, i32 1
  %95 = load i64, i64* %94, align 8, !tbaa !39
  %and110 = and i64 %95, -8
  %cmp111 = icmp eq i64 %and110, %sub.ptr.sub
  br i1 %cmp111, label %if.else138, label %if.then113

if.then113:                                       ; preds = %for.cond108
  %shr115 = lshr i64 %K95.0, 63
  %96 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %93, i64 0, i32 4, i64 %shr115
  %shl118 = shl i64 %K95.0, 1
  %97 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %96, align 8, !tbaa !38
  %cmp119 = icmp eq %struct.malloc_tree_chunk* %97, null
  %98 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %97, i64 0, i32 0
  %99 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %98) #7
  br i1 %cmp119, label %if.else122, label %for.cond108

if.else122:                                       ; preds = %if.then113
  %arrayidx117 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %T.0, i64 0, i32 4, i64 %shr115
  %100 = bitcast %struct.malloc_tree_chunk** %arrayidx117 to i8*
  %101 = getelementptr inbounds i64, i64* %8, i64 3
  %102 = bitcast i64* %101 to i8**
  %103 = load i8*, i8** %102, align 8, !tbaa !14
  %cmp124 = icmp ugt i8* %103, %100
  br i1 %cmp124, label %if.else133, label %cleanup135, !prof !34

if.else133:                                       ; preds = %if.else122
  tail call void %46() #8
  unreachable

cleanup135:                                       ; preds = %if.else122
  %104 = bitcast %struct.malloc_tree_chunk** %96 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %104, align 8, !tbaa !38
  %105 = getelementptr inbounds i64, i64* %13, i64 6
  %106 = bitcast i64* %105 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %106, align 8, !tbaa !41
  %107 = getelementptr inbounds i64, i64* %13, i64 3
  %108 = bitcast i64* %107 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %108, align 8, !tbaa !42
  %109 = getelementptr inbounds i64, i64* %13, i64 2
  %110 = bitcast i64* %109 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %110, align 8, !tbaa !43
  br label %if.end162

if.else138:                                       ; preds = %for.cond108
  %111 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %93, i64 0, i32 2
  %112 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %111, align 8, !tbaa !43
  %113 = bitcast %struct.malloc_tree_chunk* %T.0 to i8*
  %114 = getelementptr inbounds i64, i64* %8, i64 3
  %115 = bitcast i64* %114 to i8**
  %116 = load i8*, i8** %115, align 8, !tbaa !14
  %cmp142 = icmp ule i8* %116, %113
  %117 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %112, i64 0, i32 0
  %118 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %117) #7
  %119 = bitcast %struct.malloc_tree_chunk* %112 to i8*
  %cmp145 = icmp ule i8* %116, %119
  %120 = and i1 %cmp145, %cmp142
  br i1 %120, label %if.then150, label %if.else156, !prof !30

if.then150:                                       ; preds = %if.else138
  %121 = getelementptr inbounds i64, i64* %118, i64 3
  %122 = bitcast i64* %121 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %122, align 8, !tbaa !42
  %123 = bitcast %struct.malloc_tree_chunk** %111 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %11, %struct.malloc_chunk** %123, align 8, !tbaa !43
  %124 = getelementptr inbounds i64, i64* %13, i64 2
  %125 = bitcast i64* %124 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %112, %struct.malloc_tree_chunk** %125, align 8, !tbaa !43
  %126 = getelementptr inbounds i64, i64* %13, i64 3
  %127 = bitcast i64* %126 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %127, align 8, !tbaa !42
  %128 = getelementptr inbounds i64, i64* %13, i64 6
  %129 = bitcast i64* %128 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %129, align 8, !tbaa !41
  br label %if.end162

if.else156:                                       ; preds = %if.else138
  tail call void %46() #8
  unreachable

if.end162:                                        ; preds = %cleanup135, %if.end54, %if.then150, %if.then88, %for.end
  ret void
}

; Function Attrs: nounwind uwtable
define internal %struct.malloc_segment* @segment_holding(%struct.malloc_state* %m, i8* readnone %addr) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %1 = bitcast %struct.malloc_state* %m to i64*
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %1) #7
  %seg = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 16
  %3 = getelementptr inbounds i64, i64* %2, i64 111
  %4 = bitcast i64* %3 to %struct.malloc_segment*
  br label %for.cond

for.cond:                                         ; preds = %if.end, %entry
  %sp.0 = phi %struct.malloc_segment* [ %seg, %entry ], [ %13, %if.end ]
  %5 = phi %struct.malloc_segment* [ %4, %entry ], [ %13, %if.end ]
  %6 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %5, i64 0, i32 0
  %7 = load i8*, i8** %6, align 8, !tbaa !48
  %cmp = icmp ugt i8* %7, %addr
  %8 = bitcast i8* %7 to i64*
  %9 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %8) #7
  br i1 %cmp, label %if.end, label %land.lhs.true

land.lhs.true:                                    ; preds = %for.cond
  %10 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %5, i64 0, i32 1
  %11 = load i64, i64* %10, align 8, !tbaa !55
  %add.ptr = getelementptr inbounds i8, i8* %7, i64 %11
  %cmp2 = icmp ugt i8* %add.ptr, %addr
  br i1 %cmp2, label %cleanup, label %if.end

if.end:                                           ; preds = %for.cond, %land.lhs.true
  %12 = getelementptr inbounds %struct.malloc_segment, %struct.malloc_segment* %5, i64 0, i32 2
  %13 = load %struct.malloc_segment*, %struct.malloc_segment** %12, align 8, !tbaa !26
  %cmp3 = icmp eq %struct.malloc_segment* %13, null
  %14 = bitcast %struct.malloc_segment* %13 to i64*
  %15 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %14) #7
  br i1 %cmp3, label %cleanup, label %for.cond

cleanup:                                          ; preds = %if.end, %land.lhs.true
  %retval.0 = phi %struct.malloc_segment* [ %sp.0, %land.lhs.true ], [ null, %if.end ]
  ret %struct.malloc_segment* %retval.0
}

; Function Attrs: nounwind uwtable
define internal %struct.malloc_chunk* @mmap_resize(%struct.malloc_state* %m, %struct.malloc_chunk* %oldp, i64 %nb, i32 %flags) #0 {
entry:
  %0 = bitcast %struct.malloc_state* %m to i64*
  %1 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %0) #7
  %2 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* undef) #7
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* inttoptr (i64 -1 to i64*)) #7
  %4 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* getelementptr inbounds (%struct.malloc_params, %struct.malloc_params* @mparams, i64 0, i32 0)) #7
  %5 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* null) #7
  %6 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %oldp, i64 0, i32 0
  %7 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %6) #7
  %8 = getelementptr inbounds i64, i64* %7, i64 1
  %9 = load i64, i64* %8, align 8, !tbaa !11
  %and = and i64 %9, -8
  %cmp = icmp ult i64 %nb, 256
  br i1 %cmp, label %cleanup38, label %if.end

if.end:                                           ; preds = %entry
  %add = add i64 %nb, 8
  %cmp1 = icmp ult i64 %and, %add
  br i1 %cmp1, label %if.end37, label %land.lhs.true

land.lhs.true:                                    ; preds = %if.end
  %sub = sub i64 %and, %nb
  %10 = getelementptr i64, i64* %4, i64 2
  %11 = load i64, i64* %10, align 8, !tbaa !45
  %shl = shl i64 %11, 1
  %cmp2 = icmp ugt i64 %sub, %shl
  br i1 %cmp2, label %if.end37, label %cleanup38

if.end37:                                         ; preds = %if.end, %land.lhs.true
  br label %cleanup38

cleanup38:                                        ; preds = %land.lhs.true, %entry, %if.end37
  %retval.1 = phi %struct.malloc_chunk* [ null, %if.end37 ], [ null, %entry ], [ %oldp, %land.lhs.true ]
  ret %struct.malloc_chunk* %retval.1
}

; Function Attrs: nounwind uwtable
define internal void @dispose_chunk(%struct.malloc_state* %m, %struct.malloc_chunk* %p, i64 %psize) #0 {
entry:
  %0 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* bitcast (void ()* @abort to i64*)) #7
  %1 = bitcast i64* %0 to void ()*
  %2 = bitcast %struct.malloc_state* %m to i64*
  %3 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %2) #7
  %4 = bitcast i64* %3 to %struct.malloc_state*
  %5 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %p, i64 0, i32 0
  %6 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %5) #7
  %7 = bitcast %struct.malloc_chunk* %p to i8*
  %8 = bitcast i64* %6 to i8*
  %add.ptr = getelementptr inbounds i8, i8* %7, i64 %psize
  %9 = getelementptr inbounds i8, i8* %8, i64 %psize
  %10 = bitcast i8* %add.ptr to %struct.malloc_chunk*
  %11 = getelementptr inbounds i64, i64* %6, i64 1
  %12 = load i64, i64* %11, align 8, !tbaa !11
  %and = and i64 %12, 1
  %tobool = icmp eq i64 %and, 0
  br i1 %tobool, label %if.then, label %entry.if.end228_crit_edge

entry.if.end228_crit_edge:                        ; preds = %entry
  %13 = bitcast i64* %6 to %struct.malloc_chunk*
  %.pre1019 = getelementptr inbounds i64, i64* %3, i64 3
  %.pre1021 = bitcast i64* %.pre1019 to i8**
  br label %if.end228

if.then:                                          ; preds = %entry
  %14 = load i64, i64* %6, align 8, !tbaa !32
  %and2 = and i64 %12, 3
  %cmp = icmp eq i64 %and2, 0
  br i1 %cmp, label %cleanup679, label %if.end

if.end:                                           ; preds = %if.then
  %idx.neg = sub i64 0, %14
  %add.ptr5 = getelementptr inbounds i8, i8* %7, i64 %idx.neg
  %15 = getelementptr inbounds i8, i8* %8, i64 %idx.neg
  %16 = bitcast i8* %add.ptr5 to %struct.malloc_chunk*
  %17 = bitcast i8* %15 to %struct.malloc_chunk*
  %add6 = add i64 %14, %psize
  %18 = getelementptr inbounds i64, i64* %3, i64 3
  %19 = bitcast i64* %18 to i8**
  %20 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp7 = icmp ult i8* %add.ptr5, %20
  br i1 %cmp7, label %if.else225, label %if.then10, !prof !34

if.then10:                                        ; preds = %if.end
  %21 = getelementptr inbounds i64, i64* %3, i64 4
  %22 = bitcast i64* %21 to %struct.malloc_chunk**
  %23 = load %struct.malloc_chunk*, %struct.malloc_chunk** %22, align 8, !tbaa !33
  %cmp11 = icmp eq %struct.malloc_chunk* %23, %16
  br i1 %cmp11, label %if.else212, label %if.then13

if.then13:                                        ; preds = %if.then10
  %cmp14 = icmp ult i64 %14, 256
  br i1 %cmp14, label %if.then16, label %if.else64

if.then16:                                        ; preds = %if.then13
  %shr = lshr i64 %14, 3
  %24 = getelementptr inbounds i8, i8* %15, i64 16
  %25 = bitcast i8* %24 to %struct.malloc_chunk**
  %26 = load %struct.malloc_chunk*, %struct.malloc_chunk** %25, align 8, !tbaa !28
  %27 = getelementptr inbounds i8, i8* %15, i64 24
  %28 = bitcast i8* %27 to %struct.malloc_chunk**
  %29 = load %struct.malloc_chunk*, %struct.malloc_chunk** %28, align 8, !tbaa !29
  %conv18 = trunc i64 %shr to i32
  %shl1002 = shl nuw nsw i64 %shr, 1
  %idxprom = and i64 %shl1002, 4294967294
  %arrayidx = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom
  %30 = bitcast %struct.malloc_chunk** %arrayidx to %struct.malloc_chunk*
  %cmp19 = icmp eq %struct.malloc_chunk* %26, %30
  %31 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %26, i64 0, i32 0
  %32 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %31) #7
  %33 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %29, i64 0, i32 0
  %34 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %33) #7
  br i1 %cmp19, label %if.then30, label %lor.rhs

lor.rhs:                                          ; preds = %if.then16
  %35 = bitcast %struct.malloc_chunk* %26 to i8*
  %cmp22 = icmp ugt i8* %20, %35
  br i1 %cmp22, label %if.else62, label %land.rhs

land.rhs:                                         ; preds = %lor.rhs
  %36 = getelementptr inbounds i64, i64* %32, i64 3
  %37 = bitcast i64* %36 to %struct.malloc_chunk**
  %38 = load %struct.malloc_chunk*, %struct.malloc_chunk** %37, align 8, !tbaa !29
  %cmp25 = icmp eq %struct.malloc_chunk* %38, %16
  br i1 %cmp25, label %if.then30, label %if.else62, !prof !30

if.then30:                                        ; preds = %if.then16, %land.rhs
  %cmp31 = icmp eq %struct.malloc_chunk* %29, %26
  br i1 %cmp31, label %if.then33, label %if.else

if.then33:                                        ; preds = %if.then30
  %shl34 = shl i32 1, %conv18
  %neg = xor i32 %shl34, -1
  %39 = bitcast i64* %3 to i32*
  %40 = load i32, i32* %39, align 8, !tbaa !27
  %and35 = and i32 %40, %neg
  store i32 %and35, i32* %39, align 8, !tbaa !27
  br label %if.end228

if.else:                                          ; preds = %if.then30
  %cmp40 = icmp eq %struct.malloc_chunk* %29, %30
  br i1 %cmp40, label %if.else.if.then56_crit_edge, label %lor.rhs42

if.else.if.then56_crit_edge:                      ; preds = %if.else
  %.pre1027 = getelementptr inbounds i64, i64* %34, i64 2
  %.pre1029 = bitcast i64* %.pre1027 to %struct.malloc_chunk**
  br label %if.then56

lor.rhs42:                                        ; preds = %if.else
  %41 = bitcast %struct.malloc_chunk* %29 to i8*
  %42 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp44 = icmp ugt i8* %42, %41
  br i1 %cmp44, label %if.else59, label %land.rhs46

land.rhs46:                                       ; preds = %lor.rhs42
  %43 = getelementptr inbounds i64, i64* %34, i64 2
  %44 = bitcast i64* %43 to %struct.malloc_chunk**
  %45 = load %struct.malloc_chunk*, %struct.malloc_chunk** %44, align 8, !tbaa !28
  %cmp48 = icmp eq %struct.malloc_chunk* %45, %16
  br i1 %cmp48, label %if.then56, label %if.else59, !prof !30

if.then56:                                        ; preds = %if.else.if.then56_crit_edge, %land.rhs46
  %.pre-phi1030 = phi %struct.malloc_chunk** [ %.pre1029, %if.else.if.then56_crit_edge ], [ %44, %land.rhs46 ]
  %46 = getelementptr inbounds i64, i64* %32, i64 3
  %47 = bitcast i64* %46 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %29, %struct.malloc_chunk** %47, align 8, !tbaa !29
  store %struct.malloc_chunk* %26, %struct.malloc_chunk** %.pre-phi1030, align 8, !tbaa !28
  br label %if.end228

if.else59:                                        ; preds = %lor.rhs42, %land.rhs46
  tail call void %1() #8
  unreachable

if.else62:                                        ; preds = %lor.rhs, %land.rhs
  tail call void %1() #8
  unreachable

if.else64:                                        ; preds = %if.then13
  %48 = bitcast i8* %add.ptr5 to %struct.malloc_tree_chunk*
  %49 = getelementptr inbounds i8, i8* %15, i64 48
  %50 = bitcast i8* %49 to %struct.malloc_tree_chunk**
  %51 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %50, align 8, !tbaa !41
  %52 = getelementptr inbounds i8, i8* %15, i64 24
  %53 = bitcast i8* %52 to %struct.malloc_tree_chunk**
  %54 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %53, align 8, !tbaa !42
  %cmp66 = icmp eq %struct.malloc_tree_chunk* %54, %48
  %55 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %51, i64 0, i32 0
  %56 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %55) #7
  %57 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %54, i64 0, i32 0
  %58 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %57) #7
  br i1 %cmp66, label %if.else91, label %if.then68

if.then68:                                        ; preds = %if.else64
  %59 = getelementptr inbounds i8, i8* %15, i64 16
  %60 = bitcast i8* %59 to %struct.malloc_tree_chunk**
  %61 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %60, align 8, !tbaa !43
  %62 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %61, i64 0, i32 0
  %63 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %62) #7
  %64 = bitcast %struct.malloc_tree_chunk* %61 to i8*
  %cmp73 = icmp ugt i8* %20, %64
  br i1 %cmp73, label %if.else89, label %land.lhs.true

land.lhs.true:                                    ; preds = %if.then68
  %65 = getelementptr inbounds i64, i64* %63, i64 3
  %66 = bitcast i64* %65 to %struct.malloc_tree_chunk**
  %67 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %66, align 8, !tbaa !42
  %cmp76 = icmp eq %struct.malloc_tree_chunk* %67, %48
  br i1 %cmp76, label %land.rhs78, label %if.else89

land.rhs78:                                       ; preds = %land.lhs.true
  %68 = getelementptr inbounds i64, i64* %58, i64 2
  %69 = bitcast i64* %68 to %struct.malloc_tree_chunk**
  %70 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %69, align 8, !tbaa !43
  %cmp80 = icmp eq %struct.malloc_tree_chunk* %70, %48
  br i1 %cmp80, label %if.then86, label %if.else89, !prof !30

if.then86:                                        ; preds = %land.rhs78
  store %struct.malloc_tree_chunk* %54, %struct.malloc_tree_chunk** %66, align 8, !tbaa !42
  store %struct.malloc_tree_chunk* %61, %struct.malloc_tree_chunk** %69, align 8, !tbaa !43
  br label %if.end121

if.else89:                                        ; preds = %if.then68, %land.lhs.true, %land.rhs78
  tail call void %1() #8
  unreachable

if.else91:                                        ; preds = %if.else64
  %child = getelementptr inbounds i8, i8* %add.ptr5, i64 32
  %71 = getelementptr inbounds i8, i8* %15, i64 32
  %arrayidx92 = getelementptr inbounds i8, i8* %child, i64 8
  %72 = getelementptr inbounds i8, i8* %71, i64 8
  %73 = bitcast i8* %72 to %struct.malloc_tree_chunk**
  %74 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %73, align 8, !tbaa !38
  %cmp93 = icmp eq %struct.malloc_tree_chunk* %74, null
  %75 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %74, i64 0, i32 0
  %76 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %75) #7
  %77 = bitcast i64* %76 to %struct.malloc_tree_chunk*
  br i1 %cmp93, label %lor.lhs.false, label %if.then99

lor.lhs.false:                                    ; preds = %if.else91
  %78 = bitcast i8* %71 to %struct.malloc_tree_chunk**
  %79 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %78, align 8, !tbaa !38
  %cmp97 = icmp eq %struct.malloc_tree_chunk* %79, null
  %80 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %79, i64 0, i32 0
  %81 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %80) #7
  %82 = bitcast i64* %81 to %struct.malloc_tree_chunk*
  br i1 %cmp97, label %if.end121, label %if.then99

if.then99:                                        ; preds = %lor.lhs.false, %if.else91
  %RP.0.in = phi i8* [ %arrayidx92, %if.else91 ], [ %child, %lor.lhs.false ]
  %83 = phi %struct.malloc_tree_chunk** [ %73, %if.else91 ], [ %78, %lor.lhs.false ]
  %R.0 = phi %struct.malloc_tree_chunk* [ %74, %if.else91 ], [ %79, %lor.lhs.false ]
  %84 = phi %struct.malloc_tree_chunk* [ %77, %if.else91 ], [ %82, %lor.lhs.false ]
  %RP.0 = bitcast i8* %RP.0.in to %struct.malloc_tree_chunk**
  br label %while.cond

while.cond:                                       ; preds = %while.body, %if.then99
  %RP.1 = phi %struct.malloc_tree_chunk** [ %RP.0, %if.then99 ], [ %CP.0, %while.body ]
  %85 = phi %struct.malloc_tree_chunk** [ %83, %if.then99 ], [ %CP.0, %while.body ]
  %R.1 = phi %struct.malloc_tree_chunk* [ %R.0, %if.then99 ], [ %91, %while.body ]
  %86 = phi %struct.malloc_tree_chunk* [ %84, %if.then99 ], [ %91, %while.body ]
  %arrayidx101 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 1
  %87 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %86, i64 0, i32 4, i64 1
  %88 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %87, align 8, !tbaa !38
  %cmp102 = icmp eq %struct.malloc_tree_chunk* %88, null
  br i1 %cmp102, label %lor.rhs104, label %while.body

lor.rhs104:                                       ; preds = %while.cond
  %arrayidx106 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R.1, i64 0, i32 4, i64 0
  %89 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %86, i64 0, i32 4, i64 0
  %90 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %89, align 8, !tbaa !38
  %cmp107 = icmp eq %struct.malloc_tree_chunk* %90, null
  br i1 %cmp107, label %while.end, label %while.body

while.body:                                       ; preds = %lor.rhs104, %while.cond
  %91 = phi %struct.malloc_tree_chunk* [ %88, %while.cond ], [ %90, %lor.rhs104 ]
  %CP.0 = phi %struct.malloc_tree_chunk** [ %arrayidx101, %while.cond ], [ %arrayidx106, %lor.rhs104 ]
  %92 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %91, i64 0, i32 0
  %93 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %92) #7
  br label %while.cond

while.end:                                        ; preds = %lor.rhs104
  %94 = bitcast %struct.malloc_tree_chunk** %RP.1 to i8*
  %95 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp112 = icmp ugt i8* %95, %94
  br i1 %cmp112, label %if.else118, label %if.then117, !prof !34

if.then117:                                       ; preds = %while.end
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %85, align 8, !tbaa !38
  br label %if.end121

if.else118:                                       ; preds = %while.end
  tail call void %1() #8
  unreachable

if.end121:                                        ; preds = %if.then117, %lor.lhs.false, %if.then86
  %R.3 = phi %struct.malloc_tree_chunk* [ %54, %if.then86 ], [ %R.1, %if.then117 ], [ null, %lor.lhs.false ]
  %96 = phi %struct.malloc_tree_chunk* [ %54, %if.then86 ], [ %R.1, %if.then117 ], [ %82, %lor.lhs.false ]
  %cmp122 = icmp eq %struct.malloc_tree_chunk* %51, null
  br i1 %cmp122, label %if.end228, label %if.then124

if.then124:                                       ; preds = %if.end121
  %97 = getelementptr inbounds i64, i64* %3, i64 75
  %98 = bitcast i64* %97 to [32 x %struct.malloc_tree_chunk*]*
  %99 = getelementptr inbounds i8, i8* %15, i64 56
  %100 = bitcast i8* %99 to i32*
  %101 = load i32, i32* %100, align 8, !tbaa !44
  %idxprom125 = zext i32 %101 to i64
  %102 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %98, i64 0, i64 %idxprom125
  %103 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %102, align 8, !tbaa !38
  %cmp127 = icmp eq %struct.malloc_tree_chunk* %103, %48
  br i1 %cmp127, label %if.then129, label %if.else138

if.then129:                                       ; preds = %if.then124
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %102, align 8, !tbaa !38
  %cond1007 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cond1007, label %if.end159.thread, label %if.then162

if.end159.thread:                                 ; preds = %if.then129
  %shl134 = shl i32 1, %101
  %neg135 = xor i32 %shl134, -1
  %104 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %4, i64 0, i32 1
  %105 = load i32, i32* %104, align 4, !tbaa !35
  %and136 = and i32 %105, %neg135
  store i32 %and136, i32* %104, align 4, !tbaa !35
  br label %if.end228

if.else138:                                       ; preds = %if.then124
  %106 = bitcast %struct.malloc_tree_chunk* %51 to i8*
  %107 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp140 = icmp ugt i8* %107, %106
  br i1 %cmp140, label %if.else157, label %if.end159, !prof !34

if.else157:                                       ; preds = %if.else138
  tail call void %1() #8
  unreachable

if.end159:                                        ; preds = %if.else138
  %108 = getelementptr inbounds i64, i64* %56, i64 4
  %109 = bitcast i64* %108 to [2 x %struct.malloc_tree_chunk*]*
  %110 = bitcast i64* %108 to %struct.malloc_tree_chunk**
  %111 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %110, align 8, !tbaa !38
  %cmp148 = icmp ne %struct.malloc_tree_chunk* %111, %48
  %.sink = zext i1 %cmp148 to i64
  %112 = getelementptr inbounds [2 x %struct.malloc_tree_chunk*], [2 x %struct.malloc_tree_chunk*]* %109, i64 0, i64 %.sink
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %112, align 8, !tbaa !38
  %cmp160 = icmp eq %struct.malloc_tree_chunk* %R.3, null
  br i1 %cmp160, label %if.end228, label %if.then162

if.then162:                                       ; preds = %if.then129, %if.end159
  %113 = bitcast %struct.malloc_tree_chunk* %R.3 to i8*
  %114 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp164 = icmp ugt i8* %114, %113
  br i1 %cmp164, label %if.else207, label %if.then169, !prof !34

if.then169:                                       ; preds = %if.then162
  %115 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %96, i64 0, i32 5
  store %struct.malloc_tree_chunk* %51, %struct.malloc_tree_chunk** %115, align 8, !tbaa !41
  %116 = getelementptr inbounds i8, i8* %15, i64 32
  %117 = bitcast i8* %116 to %struct.malloc_tree_chunk**
  %118 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %117, align 8, !tbaa !38
  %cmp173 = icmp eq %struct.malloc_tree_chunk* %118, null
  %119 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %118, i64 0, i32 0
  %120 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %119) #7
  br i1 %cmp173, label %if.end188, label %if.then175

if.then175:                                       ; preds = %if.then169
  %121 = bitcast %struct.malloc_tree_chunk* %118 to i8*
  %122 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp177 = icmp ugt i8* %122, %121
  br i1 %cmp177, label %if.else186, label %if.then182, !prof !34

if.then182:                                       ; preds = %if.then175
  %123 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %96, i64 0, i32 4, i64 0
  store %struct.malloc_tree_chunk* %118, %struct.malloc_tree_chunk** %123, align 8, !tbaa !38
  %124 = getelementptr inbounds i64, i64* %120, i64 6
  %125 = bitcast i64* %124 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %125, align 8, !tbaa !41
  br label %if.end188

if.else186:                                       ; preds = %if.then175
  tail call void %1() #8
  unreachable

if.end188:                                        ; preds = %if.then169, %if.then182
  %126 = getelementptr inbounds i8, i8* %116, i64 8
  %127 = bitcast i8* %126 to %struct.malloc_tree_chunk**
  %128 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %127, align 8, !tbaa !38
  %cmp191 = icmp eq %struct.malloc_tree_chunk* %128, null
  %129 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %128, i64 0, i32 0
  %130 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %129) #7
  br i1 %cmp191, label %if.end228, label %if.then193

if.then193:                                       ; preds = %if.end188
  %131 = bitcast %struct.malloc_tree_chunk* %128 to i8*
  %132 = load i8*, i8** %19, align 8, !tbaa !14
  %cmp195 = icmp ugt i8* %132, %131
  br i1 %cmp195, label %if.else204, label %if.then200, !prof !34

if.then200:                                       ; preds = %if.then193
  %133 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %96, i64 0, i32 4, i64 1
  store %struct.malloc_tree_chunk* %128, %struct.malloc_tree_chunk** %133, align 8, !tbaa !38
  %134 = getelementptr inbounds i64, i64* %130, i64 6
  %135 = bitcast i64* %134 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R.3, %struct.malloc_tree_chunk** %135, align 8, !tbaa !41
  br label %if.end228

if.else204:                                       ; preds = %if.then193
  tail call void %1() #8
  unreachable

if.else207:                                       ; preds = %if.then162
  tail call void %1() #8
  unreachable

if.else212:                                       ; preds = %if.then10
  %136 = getelementptr inbounds i8, i8* %9, i64 8
  %137 = bitcast i8* %136 to i64*
  %138 = load i64, i64* %137, align 8, !tbaa !11
  %and214 = and i64 %138, 3
  %cmp215 = icmp eq i64 %and214, 3
  br i1 %cmp215, label %if.then217, label %if.end228

if.then217:                                       ; preds = %if.else212
  %139 = getelementptr inbounds i64, i64* %3, i64 1
  store i64 %add6, i64* %139, align 8, !tbaa !31
  %and219 = and i64 %138, -2
  store i64 %and219, i64* %137, align 8, !tbaa !11
  %or = or i64 %add6, 1
  %140 = getelementptr inbounds i8, i8* %15, i64 8
  %141 = bitcast i8* %140 to i64*
  store i64 %or, i64* %141, align 8, !tbaa !11
  %142 = bitcast i8* %9 to i64*
  store i64 %add6, i64* %142, align 8, !tbaa !32
  br label %cleanup679

if.else225:                                       ; preds = %if.end
  tail call void %1() #8
  unreachable

if.end228:                                        ; preds = %if.end159.thread, %entry.if.end228_crit_edge, %if.else212, %if.then33, %if.then56, %if.end159, %if.end188, %if.then200, %if.end121
  %.pre-phi1022 = phi i8** [ %.pre1021, %entry.if.end228_crit_edge ], [ %19, %if.else212 ], [ %19, %if.then33 ], [ %19, %if.then56 ], [ %19, %if.end159 ], [ %19, %if.end188 ], [ %19, %if.then200 ], [ %19, %if.end121 ], [ %19, %if.end159.thread ]
  %psize.addr.1 = phi i64 [ %psize, %entry.if.end228_crit_edge ], [ %add6, %if.else212 ], [ %add6, %if.then33 ], [ %add6, %if.then56 ], [ %add6, %if.end159 ], [ %add6, %if.end188 ], [ %add6, %if.then200 ], [ %add6, %if.end121 ], [ %add6, %if.end159.thread ]
  %p.addr.1 = phi %struct.malloc_chunk* [ %p, %entry.if.end228_crit_edge ], [ %16, %if.else212 ], [ %16, %if.then33 ], [ %16, %if.then56 ], [ %16, %if.end159 ], [ %16, %if.end188 ], [ %16, %if.then200 ], [ %16, %if.end121 ], [ %16, %if.end159.thread ]
  %143 = phi %struct.malloc_chunk* [ %13, %entry.if.end228_crit_edge ], [ %17, %if.else212 ], [ %17, %if.then33 ], [ %17, %if.then56 ], [ %17, %if.end159 ], [ %17, %if.end188 ], [ %17, %if.then200 ], [ %17, %if.end121 ], [ %17, %if.end159.thread ]
  %144 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp230 = icmp ult i8* %add.ptr, %144
  br i1 %cmp230, label %if.else677, label %if.then235, !prof !34

if.then235:                                       ; preds = %if.end228
  %145 = getelementptr inbounds i8, i8* %9, i64 8
  %146 = bitcast i8* %145 to i64*
  %147 = load i64, i64* %146, align 8, !tbaa !11
  %and237 = and i64 %147, 2
  %tobool238 = icmp eq i64 %and237, 0
  br i1 %tobool238, label %if.then239, label %if.else524

if.then239:                                       ; preds = %if.then235
  %148 = getelementptr inbounds i64, i64* %3, i64 5
  %149 = bitcast i64* %148 to %struct.malloc_chunk**
  %150 = load %struct.malloc_chunk*, %struct.malloc_chunk** %149, align 8, !tbaa !37
  %cmp240 = icmp eq %struct.malloc_chunk* %150, %10
  br i1 %cmp240, label %if.then242, label %if.else255

if.then242:                                       ; preds = %if.then239
  %151 = getelementptr inbounds i64, i64* %3, i64 2
  %152 = load i64, i64* %151, align 8, !tbaa !36
  %add243 = add i64 %152, %psize.addr.1
  store i64 %add243, i64* %151, align 8, !tbaa !36
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %149, align 8, !tbaa !37
  %or245 = or i64 %add243, 1
  %153 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 1
  store i64 %or245, i64* %153, align 8, !tbaa !11
  %154 = getelementptr inbounds i64, i64* %3, i64 4
  %155 = bitcast i64* %154 to %struct.malloc_chunk**
  %156 = load %struct.malloc_chunk*, %struct.malloc_chunk** %155, align 8, !tbaa !33
  %cmp248 = icmp eq %struct.malloc_chunk* %p.addr.1, %156
  br i1 %cmp248, label %if.then250, label %cleanup679

if.then250:                                       ; preds = %if.then242
  store %struct.malloc_chunk* null, %struct.malloc_chunk** %155, align 8, !tbaa !33
  %157 = getelementptr inbounds i64, i64* %3, i64 1
  store i64 0, i64* %157, align 8, !tbaa !31
  br label %cleanup679

if.else255:                                       ; preds = %if.then239
  %158 = getelementptr inbounds i64, i64* %3, i64 4
  %159 = bitcast i64* %158 to %struct.malloc_chunk**
  %160 = load %struct.malloc_chunk*, %struct.malloc_chunk** %159, align 8, !tbaa !33
  %cmp257 = icmp eq %struct.malloc_chunk* %160, %10
  br i1 %cmp257, label %if.then259, label %if.else268

if.then259:                                       ; preds = %if.else255
  %161 = getelementptr inbounds i64, i64* %3, i64 1
  %162 = load i64, i64* %161, align 8, !tbaa !31
  %add261 = add i64 %162, %psize.addr.1
  store i64 %add261, i64* %161, align 8, !tbaa !31
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %159, align 8, !tbaa !33
  %or263 = or i64 %add261, 1
  %163 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 1
  store i64 %or263, i64* %163, align 8, !tbaa !11
  %164 = bitcast %struct.malloc_chunk* %143 to i8*
  %165 = getelementptr inbounds i8, i8* %164, i64 %add261
  %166 = bitcast i8* %165 to i64*
  store i64 %add261, i64* %166, align 8, !tbaa !32
  br label %cleanup679

if.else268:                                       ; preds = %if.else255
  %and270 = and i64 %147, -8
  %add271 = add i64 %and270, %psize.addr.1
  %cmp273 = icmp ult i64 %147, 256
  br i1 %cmp273, label %if.then275, label %if.else342

if.then275:                                       ; preds = %if.else268
  %shr272 = lshr i64 %147, 3
  %167 = getelementptr inbounds i8, i8* %9, i64 16
  %168 = bitcast i8* %167 to %struct.malloc_chunk**
  %169 = load %struct.malloc_chunk*, %struct.malloc_chunk** %168, align 8, !tbaa !28
  %170 = getelementptr inbounds i8, i8* %9, i64 24
  %171 = bitcast i8* %170 to %struct.malloc_chunk**
  %172 = load %struct.malloc_chunk*, %struct.malloc_chunk** %171, align 8, !tbaa !29
  %conv282 = trunc i64 %shr272 to i32
  %shl2841000 = shl nuw nsw i64 %shr272, 1
  %idxprom285 = and i64 %shl2841000, 4294967294
  %arrayidx286 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom285
  %173 = bitcast %struct.malloc_chunk** %arrayidx286 to %struct.malloc_chunk*
  %cmp287 = icmp eq %struct.malloc_chunk* %169, %173
  %174 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %169, i64 0, i32 0
  %175 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %174) #7
  %176 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %172, i64 0, i32 0
  %177 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %176) #7
  br i1 %cmp287, label %if.then304, label %lor.rhs289

lor.rhs289:                                       ; preds = %if.then275
  %178 = bitcast %struct.malloc_chunk* %169 to i8*
  %cmp291 = icmp ugt i8* %144, %178
  br i1 %cmp291, label %if.else340, label %land.rhs293

land.rhs293:                                      ; preds = %lor.rhs289
  %179 = getelementptr inbounds i64, i64* %175, i64 3
  %180 = bitcast i64* %179 to %struct.malloc_chunk**
  %181 = load %struct.malloc_chunk*, %struct.malloc_chunk** %180, align 8, !tbaa !29
  %cmp295 = icmp eq %struct.malloc_chunk* %181, %10
  br i1 %cmp295, label %if.then304, label %if.else340, !prof !30

if.then304:                                       ; preds = %if.then275, %land.rhs293
  %cmp305 = icmp eq %struct.malloc_chunk* %172, %169
  br i1 %cmp305, label %if.then307, label %if.else312

if.then307:                                       ; preds = %if.then304
  %shl308 = shl i32 1, %conv282
  %neg309 = xor i32 %shl308, -1
  %182 = bitcast i64* %3 to i32*
  %183 = load i32, i32* %182, align 8, !tbaa !27
  %and311 = and i32 %183, %neg309
  store i32 %and311, i32* %182, align 8, !tbaa !27
  br label %if.end508

if.else312:                                       ; preds = %if.then304
  %cmp317 = icmp eq %struct.malloc_chunk* %172, %173
  br i1 %cmp317, label %if.else312.if.then334_crit_edge, label %lor.rhs319

if.else312.if.then334_crit_edge:                  ; preds = %if.else312
  %.pre1023 = getelementptr inbounds i64, i64* %177, i64 2
  %.pre1025 = bitcast i64* %.pre1023 to %struct.malloc_chunk**
  br label %if.then334

lor.rhs319:                                       ; preds = %if.else312
  %184 = bitcast %struct.malloc_chunk* %172 to i8*
  %185 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp321 = icmp ugt i8* %185, %184
  br i1 %cmp321, label %if.else337, label %land.rhs323

land.rhs323:                                      ; preds = %lor.rhs319
  %186 = getelementptr inbounds i64, i64* %177, i64 2
  %187 = bitcast i64* %186 to %struct.malloc_chunk**
  %188 = load %struct.malloc_chunk*, %struct.malloc_chunk** %187, align 8, !tbaa !28
  %cmp325 = icmp eq %struct.malloc_chunk* %188, %10
  br i1 %cmp325, label %if.then334, label %if.else337, !prof !30

if.then334:                                       ; preds = %if.else312.if.then334_crit_edge, %land.rhs323
  %.pre-phi1026 = phi %struct.malloc_chunk** [ %.pre1025, %if.else312.if.then334_crit_edge ], [ %187, %land.rhs323 ]
  %189 = getelementptr inbounds i64, i64* %175, i64 3
  %190 = bitcast i64* %189 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %172, %struct.malloc_chunk** %190, align 8, !tbaa !29
  store %struct.malloc_chunk* %169, %struct.malloc_chunk** %.pre-phi1026, align 8, !tbaa !28
  br label %if.end508

if.else337:                                       ; preds = %lor.rhs319, %land.rhs323
  tail call void %1() #8
  unreachable

if.else340:                                       ; preds = %lor.rhs289, %land.rhs293
  tail call void %1() #8
  unreachable

if.else342:                                       ; preds = %if.else268
  %191 = bitcast i8* %add.ptr to %struct.malloc_tree_chunk*
  %192 = getelementptr inbounds i8, i8* %9, i64 48
  %193 = bitcast i8* %192 to %struct.malloc_tree_chunk**
  %194 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %193, align 8, !tbaa !41
  %195 = getelementptr inbounds i8, i8* %9, i64 24
  %196 = bitcast i8* %195 to %struct.malloc_tree_chunk**
  %197 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %196, align 8, !tbaa !42
  %cmp348 = icmp eq %struct.malloc_tree_chunk* %197, %191
  %198 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %197, i64 0, i32 0
  %199 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %198) #7
  %200 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %194, i64 0, i32 0
  %201 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %200) #7
  br i1 %cmp348, label %if.else375, label %if.then350

if.then350:                                       ; preds = %if.else342
  %202 = getelementptr inbounds i8, i8* %9, i64 16
  %203 = bitcast i8* %202 to %struct.malloc_tree_chunk**
  %204 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %203, align 8, !tbaa !43
  %205 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %204, i64 0, i32 0
  %206 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %205) #7
  %207 = bitcast %struct.malloc_tree_chunk* %204 to i8*
  %cmp355 = icmp ugt i8* %144, %207
  br i1 %cmp355, label %if.else373, label %land.lhs.true357

land.lhs.true357:                                 ; preds = %if.then350
  %208 = getelementptr inbounds i64, i64* %206, i64 3
  %209 = bitcast i64* %208 to %struct.malloc_tree_chunk**
  %210 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %209, align 8, !tbaa !42
  %cmp359 = icmp eq %struct.malloc_tree_chunk* %210, %191
  br i1 %cmp359, label %land.rhs361, label %if.else373

land.rhs361:                                      ; preds = %land.lhs.true357
  %211 = getelementptr inbounds i64, i64* %199, i64 2
  %212 = bitcast i64* %211 to %struct.malloc_tree_chunk**
  %213 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %212, align 8, !tbaa !43
  %cmp363 = icmp eq %struct.malloc_tree_chunk* %213, %191
  br i1 %cmp363, label %if.then370, label %if.else373, !prof !30

if.then370:                                       ; preds = %land.rhs361
  store %struct.malloc_tree_chunk* %197, %struct.malloc_tree_chunk** %209, align 8, !tbaa !42
  store %struct.malloc_tree_chunk* %204, %struct.malloc_tree_chunk** %212, align 8, !tbaa !43
  br label %if.end412

if.else373:                                       ; preds = %if.then350, %land.lhs.true357, %land.rhs361
  tail call void %1() #8
  unreachable

if.else375:                                       ; preds = %if.else342
  %child377 = getelementptr inbounds i8, i8* %add.ptr, i64 32
  %214 = getelementptr inbounds i8, i8* %9, i64 32
  %arrayidx378 = getelementptr inbounds i8, i8* %child377, i64 8
  %215 = getelementptr inbounds i8, i8* %214, i64 8
  %216 = bitcast i8* %215 to %struct.malloc_tree_chunk**
  %217 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %216, align 8, !tbaa !38
  %cmp379 = icmp eq %struct.malloc_tree_chunk* %217, null
  %218 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %217, i64 0, i32 0
  %219 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %218) #7
  %220 = bitcast i64* %219 to %struct.malloc_tree_chunk*
  br i1 %cmp379, label %lor.lhs.false381, label %if.then386

lor.lhs.false381:                                 ; preds = %if.else375
  %221 = bitcast i8* %214 to %struct.malloc_tree_chunk**
  %222 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %221, align 8, !tbaa !38
  %cmp384 = icmp eq %struct.malloc_tree_chunk* %222, null
  %223 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %222, i64 0, i32 0
  %224 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %223) #7
  %225 = bitcast i64* %224 to %struct.malloc_tree_chunk*
  br i1 %cmp384, label %if.end412, label %if.then386

if.then386:                                       ; preds = %lor.lhs.false381, %if.else375
  %RP376.0.in = phi i8* [ %arrayidx378, %if.else375 ], [ %child377, %lor.lhs.false381 ]
  %226 = phi %struct.malloc_tree_chunk** [ %216, %if.else375 ], [ %221, %lor.lhs.false381 ]
  %R346.0 = phi %struct.malloc_tree_chunk* [ %217, %if.else375 ], [ %222, %lor.lhs.false381 ]
  %227 = phi %struct.malloc_tree_chunk* [ %220, %if.else375 ], [ %225, %lor.lhs.false381 ]
  %RP376.0 = bitcast i8* %RP376.0.in to %struct.malloc_tree_chunk**
  br label %while.cond388

while.cond388:                                    ; preds = %while.body400, %if.then386
  %RP376.1 = phi %struct.malloc_tree_chunk** [ %RP376.0, %if.then386 ], [ %CP387.0, %while.body400 ]
  %228 = phi %struct.malloc_tree_chunk** [ %226, %if.then386 ], [ %CP387.0, %while.body400 ]
  %R346.1 = phi %struct.malloc_tree_chunk* [ %R346.0, %if.then386 ], [ %234, %while.body400 ]
  %229 = phi %struct.malloc_tree_chunk* [ %227, %if.then386 ], [ %234, %while.body400 ]
  %arrayidx390 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R346.1, i64 0, i32 4, i64 1
  %230 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %229, i64 0, i32 4, i64 1
  %231 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %230, align 8, !tbaa !38
  %cmp391 = icmp eq %struct.malloc_tree_chunk* %231, null
  br i1 %cmp391, label %lor.rhs393, label %while.body400

lor.rhs393:                                       ; preds = %while.cond388
  %arrayidx395 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %R346.1, i64 0, i32 4, i64 0
  %232 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %229, i64 0, i32 4, i64 0
  %233 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %232, align 8, !tbaa !38
  %cmp396 = icmp eq %struct.malloc_tree_chunk* %233, null
  br i1 %cmp396, label %while.end401, label %while.body400

while.body400:                                    ; preds = %lor.rhs393, %while.cond388
  %234 = phi %struct.malloc_tree_chunk* [ %231, %while.cond388 ], [ %233, %lor.rhs393 ]
  %CP387.0 = phi %struct.malloc_tree_chunk** [ %arrayidx390, %while.cond388 ], [ %arrayidx395, %lor.rhs393 ]
  %235 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %234, i64 0, i32 0
  %236 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %235) #7
  br label %while.cond388

while.end401:                                     ; preds = %lor.rhs393
  %237 = bitcast %struct.malloc_tree_chunk** %RP376.1 to i8*
  %238 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp403 = icmp ugt i8* %238, %237
  br i1 %cmp403, label %if.else409, label %if.then408, !prof !34

if.then408:                                       ; preds = %while.end401
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %228, align 8, !tbaa !38
  br label %if.end412

if.else409:                                       ; preds = %while.end401
  tail call void %1() #8
  unreachable

if.end412:                                        ; preds = %if.then408, %lor.lhs.false381, %if.then370
  %R346.3 = phi %struct.malloc_tree_chunk* [ %197, %if.then370 ], [ null, %lor.lhs.false381 ], [ %R346.1, %if.then408 ]
  %239 = phi %struct.malloc_tree_chunk* [ %197, %if.then370 ], [ %225, %lor.lhs.false381 ], [ %R346.1, %if.then408 ]
  %cmp413 = icmp eq %struct.malloc_tree_chunk* %194, null
  br i1 %cmp413, label %if.end508, label %if.then415

if.then415:                                       ; preds = %if.end412
  %240 = getelementptr inbounds i64, i64* %3, i64 75
  %241 = bitcast i64* %240 to [32 x %struct.malloc_tree_chunk*]*
  %242 = getelementptr inbounds i8, i8* %9, i64 56
  %243 = bitcast i8* %242 to i32*
  %244 = load i32, i32* %243, align 8, !tbaa !44
  %idxprom419 = zext i32 %244 to i64
  %245 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %241, i64 0, i64 %idxprom419
  %246 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %245, align 8, !tbaa !38
  %cmp421 = icmp eq %struct.malloc_tree_chunk* %246, %191
  br i1 %cmp421, label %if.then423, label %if.else433

if.then423:                                       ; preds = %if.then415
  store %struct.malloc_tree_chunk* %R346.3, %struct.malloc_tree_chunk** %245, align 8, !tbaa !38
  %cond1008 = icmp eq %struct.malloc_tree_chunk* %R346.3, null
  br i1 %cond1008, label %if.end454.thread, label %if.then457

if.end454.thread:                                 ; preds = %if.then423
  %shl428 = shl i32 1, %244
  %neg429 = xor i32 %shl428, -1
  %247 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %4, i64 0, i32 1
  %248 = load i32, i32* %247, align 4, !tbaa !35
  %and431 = and i32 %248, %neg429
  store i32 %and431, i32* %247, align 4, !tbaa !35
  br label %if.end508

if.else433:                                       ; preds = %if.then415
  %249 = bitcast %struct.malloc_tree_chunk* %194 to i8*
  %250 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp435 = icmp ugt i8* %250, %249
  br i1 %cmp435, label %if.else452, label %if.end454, !prof !34

if.else452:                                       ; preds = %if.else433
  tail call void %1() #8
  unreachable

if.end454:                                        ; preds = %if.else433
  %251 = getelementptr inbounds i64, i64* %201, i64 4
  %252 = bitcast i64* %251 to [2 x %struct.malloc_tree_chunk*]*
  %253 = bitcast i64* %251 to %struct.malloc_tree_chunk**
  %254 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %253, align 8, !tbaa !38
  %cmp443 = icmp ne %struct.malloc_tree_chunk* %254, %191
  %.sink684 = zext i1 %cmp443 to i64
  %255 = getelementptr inbounds [2 x %struct.malloc_tree_chunk*], [2 x %struct.malloc_tree_chunk*]* %252, i64 0, i64 %.sink684
  store %struct.malloc_tree_chunk* %R346.3, %struct.malloc_tree_chunk** %255, align 8, !tbaa !38
  %cmp455 = icmp eq %struct.malloc_tree_chunk* %R346.3, null
  br i1 %cmp455, label %if.end508, label %if.then457

if.then457:                                       ; preds = %if.then423, %if.end454
  %256 = bitcast %struct.malloc_tree_chunk* %R346.3 to i8*
  %257 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp459 = icmp ugt i8* %257, %256
  br i1 %cmp459, label %if.else504, label %if.then464, !prof !34

if.then464:                                       ; preds = %if.then457
  %258 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %239, i64 0, i32 5
  store %struct.malloc_tree_chunk* %194, %struct.malloc_tree_chunk** %258, align 8, !tbaa !41
  %259 = getelementptr inbounds i8, i8* %9, i64 32
  %260 = bitcast i8* %259 to %struct.malloc_tree_chunk**
  %261 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %260, align 8, !tbaa !38
  %cmp470 = icmp eq %struct.malloc_tree_chunk* %261, null
  %262 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %261, i64 0, i32 0
  %263 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %262) #7
  br i1 %cmp470, label %if.end485, label %if.then472

if.then472:                                       ; preds = %if.then464
  %264 = bitcast %struct.malloc_tree_chunk* %261 to i8*
  %265 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp474 = icmp ugt i8* %265, %264
  br i1 %cmp474, label %if.else483, label %if.then479, !prof !34

if.then479:                                       ; preds = %if.then472
  %266 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %239, i64 0, i32 4, i64 0
  store %struct.malloc_tree_chunk* %261, %struct.malloc_tree_chunk** %266, align 8, !tbaa !38
  %267 = getelementptr inbounds i64, i64* %263, i64 6
  %268 = bitcast i64* %267 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R346.3, %struct.malloc_tree_chunk** %268, align 8, !tbaa !41
  br label %if.end485

if.else483:                                       ; preds = %if.then472
  tail call void %1() #8
  unreachable

if.end485:                                        ; preds = %if.then464, %if.then479
  %269 = getelementptr inbounds i8, i8* %259, i64 8
  %270 = bitcast i8* %269 to %struct.malloc_tree_chunk**
  %271 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %270, align 8, !tbaa !38
  %cmp488 = icmp eq %struct.malloc_tree_chunk* %271, null
  %272 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %271, i64 0, i32 0
  %273 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %272) #7
  br i1 %cmp488, label %if.end508, label %if.then490

if.then490:                                       ; preds = %if.end485
  %274 = bitcast %struct.malloc_tree_chunk* %271 to i8*
  %275 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp492 = icmp ugt i8* %275, %274
  br i1 %cmp492, label %if.else501, label %if.then497, !prof !34

if.then497:                                       ; preds = %if.then490
  %276 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %239, i64 0, i32 4, i64 1
  store %struct.malloc_tree_chunk* %271, %struct.malloc_tree_chunk** %276, align 8, !tbaa !38
  %277 = getelementptr inbounds i64, i64* %273, i64 6
  %278 = bitcast i64* %277 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %R346.3, %struct.malloc_tree_chunk** %278, align 8, !tbaa !41
  br label %if.end508

if.else501:                                       ; preds = %if.then490
  tail call void %1() #8
  unreachable

if.else504:                                       ; preds = %if.then457
  tail call void %1() #8
  unreachable

if.end508:                                        ; preds = %if.end454.thread, %if.end412, %if.then497, %if.end485, %if.end454, %if.then334, %if.then307
  %or509 = or i64 %add271, 1
  %279 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 1
  store i64 %or509, i64* %279, align 8, !tbaa !11
  %280 = bitcast %struct.malloc_chunk* %143 to i8*
  %281 = getelementptr inbounds i8, i8* %280, i64 %add271
  %282 = bitcast i8* %281 to i64*
  store i64 %add271, i64* %282, align 8, !tbaa !32
  %283 = load %struct.malloc_chunk*, %struct.malloc_chunk** %159, align 8, !tbaa !33
  %cmp514 = icmp eq %struct.malloc_chunk* %p.addr.1, %283
  br i1 %cmp514, label %if.then516, label %if.end531

if.then516:                                       ; preds = %if.end508
  %284 = getelementptr inbounds i64, i64* %3, i64 1
  store i64 %add271, i64* %284, align 8, !tbaa !31
  br label %cleanup679

if.else524:                                       ; preds = %if.then235
  %and526 = and i64 %147, -2
  store i64 %and526, i64* %146, align 8, !tbaa !11
  %or527 = or i64 %psize.addr.1, 1
  %285 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 1
  store i64 %or527, i64* %285, align 8, !tbaa !11
  %286 = bitcast %struct.malloc_chunk* %143 to i8*
  %287 = getelementptr inbounds i8, i8* %286, i64 %psize.addr.1
  %288 = bitcast i8* %287 to i64*
  store i64 %psize.addr.1, i64* %288, align 8, !tbaa !32
  br label %if.end531

if.end531:                                        ; preds = %if.end508, %if.else524
  %psize.addr.2 = phi i64 [ %psize.addr.1, %if.else524 ], [ %add271, %if.end508 ]
  %cmp533 = icmp ult i64 %psize.addr.2, 256
  br i1 %cmp533, label %if.then535, label %if.else570

if.then535:                                       ; preds = %if.end531
  %shr532 = lshr i64 %psize.addr.2, 3
  %conv538 = trunc i64 %shr532 to i32
  %289 = getelementptr inbounds i64, i64* %3, i64 9
  %290 = bitcast i64* %289 to [66 x %struct.malloc_chunk*]*
  %shl541998 = shl nuw nsw i64 %shr532, 1
  %idxprom542 = and i64 %shl541998, 4294967294
  %arrayidx543 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 10, i64 %idxprom542
  %291 = getelementptr inbounds [66 x %struct.malloc_chunk*], [66 x %struct.malloc_chunk*]* %290, i64 0, i64 %idxprom542
  %292 = bitcast i64* %3 to i32*
  %293 = load i32, i32* %292, align 8, !tbaa !27
  %shl546 = shl i32 1, %conv538
  %and547 = and i32 %293, %shl546
  %tobool548 = icmp eq i32 %and547, 0
  br i1 %tobool548, label %if.then549, label %if.else553

if.then549:                                       ; preds = %if.then535
  %294 = bitcast %struct.malloc_chunk** %291 to %struct.malloc_chunk*
  %295 = bitcast %struct.malloc_chunk** %arrayidx543 to %struct.malloc_chunk*
  %or552 = or i32 %293, %shl546
  store i32 %or552, i32* %292, align 8, !tbaa !27
  %.pre = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %291, i64 2
  br label %if.end565

if.else553:                                       ; preds = %if.then535
  %296 = getelementptr inbounds %struct.malloc_chunk*, %struct.malloc_chunk** %291, i64 2
  %297 = load %struct.malloc_chunk*, %struct.malloc_chunk** %296, align 8, !tbaa !28
  %298 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %297, i64 0, i32 0
  %299 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %298) #7
  %300 = bitcast %struct.malloc_chunk* %297 to i8*
  %301 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp556 = icmp ugt i8* %301, %300
  br i1 %cmp556, label %if.else563, label %if.end565, !prof !34

if.else563:                                       ; preds = %if.else553
  tail call void %1() #8
  unreachable

if.end565:                                        ; preds = %if.else553, %if.then549
  %.pre-phi = phi %struct.malloc_chunk** [ %296, %if.else553 ], [ %.pre, %if.then549 ]
  %F544.0 = phi %struct.malloc_chunk* [ %297, %if.else553 ], [ %295, %if.then549 ]
  %302 = phi %struct.malloc_chunk* [ %297, %if.else553 ], [ %294, %if.then549 ]
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %.pre-phi, align 8, !tbaa !28
  %303 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %302, i64 0, i32 3
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %303, align 8, !tbaa !29
  %304 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 2
  store %struct.malloc_chunk* %F544.0, %struct.malloc_chunk** %304, align 8, !tbaa !28
  %305 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 3
  %306 = bitcast %struct.malloc_chunk** %305 to %struct.malloc_chunk***
  store %struct.malloc_chunk** %arrayidx543, %struct.malloc_chunk*** %306, align 8, !tbaa !29
  br label %cleanup679

if.else570:                                       ; preds = %if.end531
  %shr574 = lshr i64 %psize.addr.2, 8
  %conv575 = trunc i64 %shr574 to i32
  %cmp576 = icmp eq i32 %conv575, 0
  br i1 %cmp576, label %if.end592, label %if.else579

if.else579:                                       ; preds = %if.else570
  %cmp580 = icmp ugt i32 %conv575, 65535
  br i1 %cmp580, label %if.end592, label %if.else583

if.else583:                                       ; preds = %if.else579
  %307 = tail call i32 @llvm.ctlz.i32(i32 %conv575, i1 true)
  %sub = xor i32 %307, 31
  %shl584 = shl nuw nsw i32 %sub, 1
  %conv585 = zext i32 %shl584 to i64
  %add586 = add nuw nsw i32 %sub, 7
  %sh_prom = zext i32 %add586 to i64
  %shr587 = lshr i64 %psize.addr.2, %sh_prom
  %and588 = and i64 %shr587, 1
  %add589 = or i64 %and588, %conv585
  %conv590 = trunc i64 %add589 to i32
  br label %if.end592

if.end592:                                        ; preds = %if.else579, %if.else570, %if.else583
  %I573.0 = phi i32 [ %conv590, %if.else583 ], [ 0, %if.else570 ], [ 31, %if.else579 ]
  %308 = getelementptr inbounds i64, i64* %3, i64 75
  %309 = bitcast i64* %308 to [32 x %struct.malloc_tree_chunk*]*
  %idxprom594 = zext i32 %I573.0 to i64
  %310 = getelementptr inbounds [32 x %struct.malloc_tree_chunk*], [32 x %struct.malloc_tree_chunk*]* %309, i64 0, i64 %idxprom594
  %311 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 1, i32 3
  %312 = bitcast %struct.malloc_chunk** %311 to i32*
  store i32 %I573.0, i32* %312, align 8, !tbaa !44
  %313 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 1
  %314 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %4, i64 0, i32 1
  %315 = bitcast %struct.malloc_chunk* %313 to i8*
  call void @llvm.memset.p0i8.i64(i8* %315, i8 0, i64 16, i32 8, i1 false)
  %316 = load i32, i32* %314, align 4, !tbaa !35
  %shl602 = shl i32 1, %I573.0
  %and603 = and i32 %316, %shl602
  %tobool604 = icmp eq i32 %and603, 0
  br i1 %tobool604, label %if.then605, label %if.else612

if.then605:                                       ; preds = %if.end592
  %arrayidx595 = getelementptr inbounds %struct.malloc_state, %struct.malloc_state* %m, i64 0, i32 11, i64 %idxprom594
  %or608 = or i32 %316, %shl602
  store i32 %or608, i32* %314, align 4, !tbaa !35
  %317 = bitcast %struct.malloc_tree_chunk** %310 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %317, align 8, !tbaa !38
  %318 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 1, i32 2
  %319 = bitcast %struct.malloc_chunk** %318 to %struct.malloc_tree_chunk***
  store %struct.malloc_tree_chunk** %arrayidx595, %struct.malloc_tree_chunk*** %319, align 8, !tbaa !41
  %320 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 3
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %320, align 8, !tbaa !42
  %321 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 2
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %321, align 8, !tbaa !43
  br label %cleanup679

if.else612:                                       ; preds = %if.end592
  %322 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %310, align 8, !tbaa !38
  %cmp614 = icmp eq i32 %I573.0, 31
  %323 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %322, i64 0, i32 0
  %324 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %323) #7
  %325 = bitcast i64* %324 to %struct.malloc_tree_chunk*
  br i1 %cmp614, label %cond.end, label %cond.false

cond.false:                                       ; preds = %if.else612
  %shr616 = lshr i32 %I573.0, 1
  %sub618 = add nuw i32 %shr616, 6
  %conv619 = zext i32 %sub618 to i64
  %sub620 = sub nsw i64 63, %conv619
  br label %cond.end

cond.end:                                         ; preds = %if.else612, %cond.false
  %cond = phi i64 [ %sub620, %cond.false ], [ 0, %if.else612 ]
  %shl621 = shl i64 %psize.addr.2, %cond
  br label %for.cond

for.cond:                                         ; preds = %if.then626, %cond.end
  %T.0 = phi %struct.malloc_tree_chunk* [ %322, %cond.end ], [ %330, %if.then626 ]
  %326 = phi %struct.malloc_tree_chunk* [ %325, %cond.end ], [ %330, %if.then626 ]
  %K613.0 = phi i64 [ %shl621, %cond.end ], [ %shl631, %if.then626 ]
  %327 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %326, i64 0, i32 1
  %328 = load i64, i64* %327, align 8, !tbaa !39
  %and623 = and i64 %328, -8
  %cmp624 = icmp eq i64 %and623, %psize.addr.2
  br i1 %cmp624, label %if.else651, label %if.then626

if.then626:                                       ; preds = %for.cond
  %shr628 = lshr i64 %K613.0, 63
  %329 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %326, i64 0, i32 4, i64 %shr628
  %shl631 = shl i64 %K613.0, 1
  %330 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %329, align 8, !tbaa !38
  %cmp632 = icmp eq %struct.malloc_tree_chunk* %330, null
  %331 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %330, i64 0, i32 0
  %332 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %331) #7
  br i1 %cmp632, label %if.else635, label %for.cond

if.else635:                                       ; preds = %if.then626
  %arrayidx630 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %T.0, i64 0, i32 4, i64 %shr628
  %333 = bitcast %struct.malloc_tree_chunk** %arrayidx630 to i8*
  %334 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp637 = icmp ugt i8* %334, %333
  br i1 %cmp637, label %if.else646, label %cleanup648, !prof !34

if.else646:                                       ; preds = %if.else635
  tail call void %1() #8
  unreachable

cleanup648:                                       ; preds = %if.else635
  %335 = bitcast %struct.malloc_tree_chunk** %329 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %335, align 8, !tbaa !38
  %336 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 1, i32 2
  %337 = bitcast %struct.malloc_chunk** %336 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %337, align 8, !tbaa !41
  %338 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 3
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %338, align 8, !tbaa !42
  %339 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 2
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %339, align 8, !tbaa !43
  br label %cleanup679

if.else651:                                       ; preds = %for.cond
  %340 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %326, i64 0, i32 2
  %341 = load %struct.malloc_tree_chunk*, %struct.malloc_tree_chunk** %340, align 8, !tbaa !43
  %342 = bitcast %struct.malloc_tree_chunk* %T.0 to i8*
  %343 = load i8*, i8** %.pre-phi1022, align 8, !tbaa !14
  %cmp655 = icmp ule i8* %343, %342
  %344 = getelementptr inbounds %struct.malloc_tree_chunk, %struct.malloc_tree_chunk* %341, i64 0, i32 0
  %345 = tail call i64* asm "rorx $$0xc,$1,%r14;add (%r15d,%r14d,8),%r14;rorx $$0x34,%r14,$0", "=r,r,~{dirflag},~{fpsr},~{flags}"(i64* %344) #7
  %346 = bitcast %struct.malloc_tree_chunk* %341 to i8*
  %cmp659 = icmp ule i8* %343, %346
  %347 = and i1 %cmp659, %cmp655
  br i1 %347, label %if.then666, label %if.else672, !prof !30

if.then666:                                       ; preds = %if.else651
  %348 = getelementptr inbounds i64, i64* %345, i64 3
  %349 = bitcast i64* %348 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %349, align 8, !tbaa !42
  %350 = bitcast %struct.malloc_tree_chunk** %340 to %struct.malloc_chunk**
  store %struct.malloc_chunk* %p.addr.1, %struct.malloc_chunk** %350, align 8, !tbaa !43
  %351 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 2
  %352 = bitcast %struct.malloc_chunk** %351 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %341, %struct.malloc_tree_chunk** %352, align 8, !tbaa !43
  %353 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 0, i32 3
  %354 = bitcast %struct.malloc_chunk** %353 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* %T.0, %struct.malloc_tree_chunk** %354, align 8, !tbaa !42
  %355 = getelementptr inbounds %struct.malloc_chunk, %struct.malloc_chunk* %143, i64 1, i32 2
  %356 = bitcast %struct.malloc_chunk** %355 to %struct.malloc_tree_chunk**
  store %struct.malloc_tree_chunk* null, %struct.malloc_tree_chunk** %356, align 8, !tbaa !41
  br label %cleanup679

if.else672:                                       ; preds = %if.else651
  tail call void %1() #8
  unreachable

if.else677:                                       ; preds = %if.end228
  tail call void %1() #8
  unreachable

cleanup679:                                       ; preds = %if.then, %cleanup648, %if.then217, %if.end565, %if.then666, %if.then605, %if.then516, %if.then242, %if.then250, %if.then259
  ret void
}

; Function Attrs: nounwind
declare i32 @fprintf(%struct._IO_FILE* nocapture, i8* nocapture readonly, ...) #6

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="true" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind }
attributes #3 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind readnone }
attributes #5 = { nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nounwind }
attributes #8 = { noreturn nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 5.0.0 "}
!1 = !{!2, !3, i64 0}
!2 = !{!"malloc_params", !3, i64 0, !3, i64 8, !3, i64 16, !3, i64 24, !3, i64 32, !6, i64 40}
!3 = !{!"long", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!"int", !4, i64 0}
!7 = !{!2, !3, i64 8}
!8 = !{!3, !3, i64 0}
!9 = !{!2, !3, i64 32}
!10 = !{!2, !6, i64 40}
!11 = !{!12, !3, i64 8}
!12 = !{!"malloc_chunk", !3, i64 0, !3, i64 8, !13, i64 16, !13, i64 24}
!13 = !{!"any pointer", !4, i64 0}
!14 = !{!15, !13, i64 24}
!15 = !{!"malloc_state", !6, i64 0, !6, i64 4, !3, i64 8, !3, i64 16, !13, i64 24, !13, i64 32, !13, i64 40, !3, i64 48, !3, i64 56, !3, i64 64, !4, i64 72, !4, i64 600, !3, i64 856, !3, i64 864, !3, i64 872, !6, i64 880, !16, i64 888, !13, i64 920, !3, i64 928}
!16 = !{!"malloc_segment", !13, i64 0, !3, i64 8, !13, i64 16, !6, i64 24}
!17 = !{!15, !13, i64 888}
!18 = !{!15, !3, i64 864}
!19 = !{!15, !3, i64 856}
!20 = !{!15, !3, i64 896}
!21 = !{!15, !3, i64 64}
!22 = !{!15, !3, i64 56}
!23 = !{!6, !6, i64 0}
!24 = !{!15, !6, i64 880}
!25 = !{!15, !6, i64 912}
!26 = !{!16, !13, i64 16}
!27 = !{!15, !6, i64 0}
!28 = !{!12, !13, i64 16}
!29 = !{!12, !13, i64 24}
!30 = !{!"branch_weights", i32 2000, i32 1}
!31 = !{!15, !3, i64 8}
!32 = !{!12, !3, i64 0}
!33 = !{!15, !13, i64 32}
!34 = !{!"branch_weights", i32 1, i32 2000}
!35 = !{!15, !6, i64 4}
!36 = !{!15, !3, i64 16}
!37 = !{!15, !13, i64 40}
!38 = !{!13, !13, i64 0}
!39 = !{!40, !3, i64 8}
!40 = !{!"malloc_tree_chunk", !3, i64 0, !3, i64 8, !13, i64 16, !13, i64 24, !4, i64 32, !13, i64 48, !6, i64 56}
!41 = !{!40, !13, i64 48}
!42 = !{!40, !13, i64 24}
!43 = !{!40, !13, i64 16}
!44 = !{!40, !6, i64 56}
!45 = !{!2, !3, i64 16}
!46 = !{!15, !3, i64 872}
!47 = !{!15, !3, i64 48}
!48 = !{!16, !13, i64 0}
!49 = distinct !{!49, !50, !51}
!50 = !{!"llvm.loop.vectorize.width", i32 1}
!51 = !{!"llvm.loop.interleave.count", i32 1}
!52 = distinct !{!52, !53, !50, !51}
!53 = !{!"llvm.loop.unroll.runtime.disable"}
!54 = !{!"branch_weights", i32 2002, i32 2000}
!55 = !{!16, !3, i64 8}
!56 = !{!2, !3, i64 24}
!57 = !{i64 0, i64 8, !38, i64 8, i64 8, !8, i64 16, i64 8, !38, i64 24, i64 4, !23}
!58 = !{!15, !13, i64 904}
