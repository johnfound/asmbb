
sqlGetAttachedFile text "select filename, file from Attachments where id = ?1"

proc GetAttachedFile, .pSpecial
.stmt      dd ?
.fileid    dd ?
begin
        pushad

        mov     esi, [.pSpecial]
        stdcall TextCreate, sizeof.TText
        mov     edi, eax

; check permissions

        test    [esi+TSpecialParams.userStatus], permDownload or permAdmin
        jz      .error_403

; extract the file from the database

        lea     eax, [.stmt]
        cinvoke sqlitePrepare_v2, [hMainDatabase], sqlGetAttachedFile, sqlGetAttachedFile.length, eax, 0

        mov     edx, [esi+TSpecialParams.cmd_list]
        cmp     [edx+TArray.count], 0
        je      .error_404

        stdcall StrToNumEx, [edx+TArray.array]
        jc      .error_404

        mov     [.fileid], eax

        cinvoke sqliteBindInt, [.stmt], 1, eax
        cinvoke sqliteStep, [.stmt]
        cmp     eax, SQLITE_ROW
        jne     .error_404

; First the headers. Only for download.

        stdcall TextCat, edi, <"Content-type: application/octet-stream", 13, 10, "Content-Disposition: attachment; filename*=utf-8''">
        mov     edi, edx

        cinvoke sqliteColumnText, [.stmt], 0            ; the filename.

        stdcall StrURLEncode, eax
        stdcall TextCat, edi, eax
        stdcall StrDel, eax
        stdcall TextCat, edx, <txt 13, 10, 13, 10>
        mov     edi, edx

        cinvoke sqliteColumnBytes, [.stmt], 1
        mov     ebx, eax
        cinvoke sqliteColumnBlob, [.stmt], 1

        stdcall TextAddStr2, edi, -1, eax, ebx
        mov     edi, edx

        stdcall AttachmentIncDownloadCount, [.fileid]

.finalize:
        cinvoke sqliteFinalize, [.stmt]

.finish:
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
        jmp     .finish

endp



sqlIncDownloadCnt  text "update Attachments set dcnt = dcnt + 1 where id = ?1"

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
