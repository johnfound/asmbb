

macro BenchmarkStart tempvar {

  if defined options.Benchmark & options.Benchmark
        push eax
        stdcall GetFineTimestamp
        mov     [tempvar], eax
        pop  eax
  end if

  macro Benchmark [txtLabel] \{
  \common
    if defined options.Benchmark & options.Benchmark
          push  eax
  \forward
          stdcall FileWriteString, [STDERR], txtLabel
  \common
          stdcall GetFineTimestamp
          sub     eax, [tempvar]

          stdcall NumToStr, eax, ntsDec or ntsUnsigned
          push    eax
          stdcall FileWriteString, [STDERR], eax
          stdcall FileWriteString, [STDERR], <txt 13, 10>
          stdcall StrDel ; from the stack
          pop  eax
    end if
  \}



}


macro BenchVar name {
  if defined options.Benchmark & options.Benchmark
    name dd ?
  end if
}


macro BenchmarkEnd {
  purge Benchmark
}