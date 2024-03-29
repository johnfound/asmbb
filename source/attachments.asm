MAX_ATTACHMENT_COUNT = 10
MAX_ATTACHMENT_SIZE = 1024*1024

sqlGetAttachedFile text "select filename, file, key from Attachments where id = ?1"
sqlGetFileDate     text "select changed from Attachments where id = ?1"

proc GetAttachedFile, .pSpecial
.stmt      dd ?
.fileid    dd ?
.pKey      dd ?
.pKeyLen   dd ?

.date     TDateTime
.timelo    dd ?
.timehi    dd ?
.timeRetLo dd ?
.timeRetHi dd ?

BenchVar .attachit
begin
        pushad

        BenchmarkStart .attachit

        xor     eax, eax
        mov     [.stmt], eax
        mov     [.timelo], eax
        mov     [.timehi], eax

        mov     esi, [.pSpecial]
        stdcall TextCreate, sizeof.TText
        mov     edi, eax

; check permissions

        test    [esi+TSpecialParams.userStatus], permDownload or permAdmin
        jz      .error_403

        mov     edx, [esi+TSpecialParams.cmd_list]
        cmp     [edx+TArray.count], 0
        je      .error_404

        stdcall StrToNumEx, [edx+TArray.array]
        jc      .error_404

        mov     [.fileid], eax

; Check the caching.

        stdcall ValueByName, [esi + TSpecialParams.params], "HTTP_IF_MODIFIED_SINCE"
        jc      .file_time

        lea     edx, [.date]
        stdcall DecodeHTTPDate, eax, edx
        jc      .file_time

        stdcall DateTimeToTime, edx
        mov     [.timelo], eax
        mov     [.timehi], edx

.file_time:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetFileDate, sqlGetFileDate.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.fileid]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_404

        cinvoke sqliteColumnInt64, [.stmt], 0
        mov     [.timeRetLo], eax
        mov     [.timeRetHi], edx

        cinvoke sqliteFinalize, [.stmt]
        and     [.stmt], 0

        mov     edx, [.timeRetHi]
        mov     eax, [.timeRetLo]

        cmp     edx, [.timehi]
        jg      .extract_the_file       ; the file is newer than in the client.
        jl      .return_304

        cmp     eax, [.timelo]
        jg      .extract_the_file       ; the file is newer than in the client.

.return_304:
        stdcall TextCat, edi, <"Status: 304 Not Modified", 13, 10, 13, 10>
        mov     edi, edx
        jmp     .finish

; extract the file from the database

.extract_the_file:
        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetAttachedFile, sqlGetAttachedFile.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.fileid]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_404

; Generate the headers. Only for download.

        stdcall TextCat, edi, <"Cache-control: max-age=1000000", 13, 10>
        stdcall FormatHTTPTime, [.timeRetLo], [.timeRetHi]
        stdcall TextCat, edx, "Last-modified: "
        stdcall TextCat, edx, eax
        stdcall StrDel, eax

        stdcall TextCat, edx, <13, 10, "Content-type: application/octet-stream", 13, 10, "Content-Disposition: attachment; filename*=utf-8''">
        mov     edi, edx

        cinvoke sqliteColumnText, [.stmt], 0            ; the filename.

        stdcall StrURLEncode, eax
        stdcall TextCat, edi, eax
        stdcall StrDel, eax
        stdcall TextCat, edx, <txt 13, 10, 13, 10>
        mov     edi, edx

        cinvoke sqliteColumnBlob, [.stmt], 2
        mov     [.pKey], eax
        cinvoke sqliteColumnBytes, [.stmt], 2
        test    eax, 3
        jnz     .error_403      ; broken file!

        mov     [.pKeyLen], eax

        cinvoke sqliteColumnBlob, [.stmt], 1
        mov     ebx, eax
        cinvoke sqliteColumnBytes, [.stmt], 1
        mov     ecx, eax

        stdcall XorMemory, ebx, ecx, [.pKey], [.pKeyLen]

;        OutputValue "Attached file size: ", ecx, 10, -1

        stdcall TextAddBytes, edi, -1, ebx, ecx
        mov     edi, edx

        stdcall AttachmentIncDownloadCount, [.fileid]

.finalize:
        cinvoke sqliteFinalize, [.stmt]

.finish:
        Benchmark "Time to process one attached file: "
        BenchmarkEnd

        mov     [esp+4*regEAX], edi
        stc
        popad
        return

.error_404:
        stdcall AppendError, edi, "404 Not Found", esi
        mov     edi, edx
        jmp     .finalize


.error_403:
        stdcall AppendError, edi, "403 Forbidden", esi
        mov     edi, edx
        jmp     .finalize

endp



sqlIncDownloadCnt  text "update attachCnt set count = count + 1 where fileid = ?1"

proc AttachmentIncDownloadCount, .fileID
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlIncDownloadCnt, sqlIncDownloadCnt.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.fileID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp




sqlAttach text "insert into Attachments(userID, filename, file, changed, md5sum, key) values (?1, ?2, ?3, strftime('%s','now'), ?4, ?5)"
sqlAttachCnt text "select count() from Attachments where (postid is not null and postid = ?1) or (postid is null and userid = ?2)"

proc WriteAttachments, .postID, .userID, .pSpecial
.stmt dd ?
.max_size dd ?
.max_count dd ?
begin
        pushad
        mov     ebx, [.pSpecial]

        DebugMsg "Write attachments"

        test    [ebx+TSpecialParams.userStatus], permAttach or permAdmin
        jz      .error_permissions

        stdcall ValueByName, [ebx+TSpecialParams.post_array], txt "attach"
        jc      .error_post_data

        mov     esi, eax        ; TArray of TPostFileItem
        and     eax, $c0000000
        jnz     .error_post_data        ; it is a string instead of array of attached files.

; get the limits.

        mov     eax, MAX_ATTACHMENT_SIZE
        stdcall GetParam, "max_attachment_size", gpInteger
        mov     [.max_size], eax

;        OutputValue "Max attachment size:", eax, 10, -1

        mov     eax, MAX_ATTACHMENT_COUNT
        stdcall GetParam, "max_attachment_count", gpInteger
        mov     [.max_count], eax

;        OutputValue "Max attachment count:", eax, 10, -1
;        OutputValue "Post ID = ", [.postID], 10, -1

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlAttachCnt, sqlAttachCnt.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.postID]
        cinvoke sqliteBindInt, [.stmt], 2, [.userID]
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_finalize

        cinvoke sqliteColumnInt, [.stmt], 0
        mov     ebx, eax
        cinvoke sqliteFinalize, [.stmt]

;        OutputValue "Attachment count now:", eax, 10, -1

        sub     [.max_count], ebx
        jle     .error_limits

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlAttach, sqlAttach.length, eax, 0

        mov     ebx, [esi+TArray.count]
        lea     esi, [esi+TArray.array]

.loop:
        dec     ebx
        js      .end_of_files

        mov     eax, [esi+TPostFileItem.size]
        test    eax, eax
        jz      .next

        cmp     eax, [.max_size]
        ja      .next

        cinvoke sqliteBindInt, [.stmt], 1, [.userID]

        stdcall StrPtr, [esi+TPostFileItem.filename]
        cinvoke sqliteBindText, [.stmt], 2, eax, [eax+string.len], SQLITE_STATIC

        stdcall DataMD5, [esi+TPostFileItem.data], [esi+TPostFileItem.size]
        push    eax
        stdcall StrPtr, eax
        cinvoke sqliteBindText, [.stmt], 4, eax, [eax+string.len], SQLITE_TRANSIENT
        stdcall StrDel ; from the stack

;        DebugMsg "MD4 computed."

        stdcall GetRandomBytes, 256
        jc      .clear
        mov     edi, eax

;        DebugMsg "Encription key created."

        stdcall XorMemory, [esi+TPostFileItem.data], [esi+TPostFileItem.size], edi, 256

;        DebugMsg "File encrypted."

        cinvoke sqliteBindBlob, [.stmt], 3, [esi+TPostFileItem.data], [esi+TPostFileItem.size], SQLITE_STATIC
        cinvoke sqliteBindBlob, [.stmt], 5, edi, 256, SQLITE_STATIC

        cinvoke sqliteStep, [.stmt]

        stdcall FreeMem, edi

        cmp     eax, SQLITE_DONE
        jne     .clear

        dec     [.max_count]
        jz      .end_of_files

.clear:
        cinvoke sqliteClearBindings, [.stmt]
        cinvoke sqliteReset, [.stmt]

.next:
        add     esi, sizeof.TPostFileItem
        jmp     .loop

.end_of_files:
        cinvoke sqliteFinalize, [.stmt]
        clc
        popad
        return


.error_finalize:

        cinvoke sqliteFinalize, [.stmt]

.error_limits:
.error_permissions:
.error_post_data:
        stc
        popad
        return
endp



proc DelAttachments, .postID, .userID, .pSpecial
begin
        pushad
        mov     esi, [.pSpecial]
        mov     edx, [esi+TSpecialParams.post_array]

; now search the files that need to be deleted:

        mov     ecx, [edx+TArray.count]

.loop:
        dec     ecx
        js      .finish

        stdcall StrCompNoCase, [edx+TArray.array + 8*ecx], txt 'attch_del'
        jnc     .loop

        mov     eax, [edx+TArray.array + 8*ecx + 4]
        cmp     eax, $c0000000
        jb      .loop

        stdcall StrToNumEx, eax
        jc      .loop

        stdcall __DelOneFile, [.postID], [.userID], eax
        jmp     .loop

.finish:
        popad
        return
endp



sqlDelFile text "delete from Attachments where id = ?1 and ((postid is not null and postid = ?2) or (postid is null and userid = ?3))"

proc __DelOneFile, .postID, .userID, .fileID
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlDelFile, sqlDelFile.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.fileID]

        cmp     [.postID], 0
        je      @f
        cinvoke sqliteBindInt, [.stmt], 2, [.postID]
@@:
        cinvoke sqliteBindInt, [.stmt], 3, [.userID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp




sqlUpdateAttach text "update Attachments set postID = ?1, userID = null where postID is null and userID = ?2"

proc UpdateAttachmentsPost, .postID, .userID
.stmt dd ?
begin
        pushad

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlUpdateAttach, sqlUpdateAttach.length, eax, 0
        cinvoke sqliteBindInt, [.stmt], 1, [.postID]
        cinvoke sqliteBindInt, [.stmt], 2, [.userID]
        cinvoke sqliteStep, [.stmt]
        cinvoke sqliteFinalize, [.stmt]

        popad
        return
endp






proc XorMemory, .pData, .DataSize, .pKey, .KeyLen
begin
        pushad
        shr     [.KeyLen], 2    ; MUST BE DWORD SIZED

        mov     esi, [.pData]
        mov     ecx, [.DataSize]


.loop_key:
        mov     edi, [.pKey]
        mov     edx, [.KeyLen]
.loop:
        cmp     ecx, 4
        jb      .final_bytes

        mov     eax, [esi]
        xor     eax, [edi]
        mov     [esi], eax

        add     esi, 4
        add     edi, 4
        sub     ecx, 4
        dec     edx
        jnz     .loop
        jmp     .loop_key

.final_bytes:
        dec     ecx
        js      .finish

        mov     al, [esi]
        xor     al, [edi]
        mov     [esi], al
        inc     esi
        inc     edi
        jmp     .final_bytes

.finish:
        popad
        return
endp

