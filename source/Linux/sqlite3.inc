; _______________________________________________________________________________________
;|                                                                                       |
;| ..::FreshLib::..  Free, open source. Licensed under "BSD 2-clause" license."          |
;|_______________________________________________________________________________________|
;
;  Description: sqlite3.dll API calls
;
;  Target OS: Win32
;
;  Dependencies:
;
;  Notes:
;_________________________________________________________________________________________


import_proto './libsqlite3.so',  \
    sqliteAggregateContext, <.context, .nbytes>,  'sqlite3_aggregate_context',  \
    sqliteAggregateCount_OLD, <VOID>,  'sqlite3_aggregate_count',  \
    sqliteAutoExtension, <.ptrCallback>,  'sqlite3_auto_extension',  \
    sqliteBackupFinish, <.ptrBackup>,  'sqlite3_backup_finish',  \
    sqliteBackupInit, <.ptrDestDB, .ptrDestName, .ptrSourceDB, .ptrSourceName>,  'sqlite3_backup_init',  \
    sqliteBackupPageCount, <.ptrBackup>,  'sqlite3_backup_pagecount',  \
    sqliteBackupRemaining, <.ptrBackup>,  'sqlite3_backup_remaining',  \
    sqliteBackupStep, <.ptrBackup, .nPage>,  'sqlite3_backup_step',  \
    sqliteBindBlob, <.stmt, .index, .ptrData, .nbytes, .destructor>,  'sqlite3_bind_blob',  \
    sqliteBindDouble, <.stmt, .index, .value>,  'sqlite3_bind_double',  \
    sqliteBindInt, <.stmt, .index, .value>,  'sqlite3_bind_int',  \
    sqliteBindInt64, <.stmt, .index, .valueLo, .valueHi>,  'sqlite3_bind_int64',  \
    sqliteBindNull, <.stmt, .index>,  'sqlite3_bind_null',  \
    sqliteBindParameterCount, <.stmt>,  'sqlite3_bind_parameter_count',  \
    sqliteBindParameterIndex, <.stmt, .paramName>,  'sqlite3_bind_parameter_index',  \
    sqliteBindParameterName, <.stmt, .paramIndex>,  'sqlite3_bind_parameter_name',  \
    sqliteBindText, <.stmt, .index, .ptrText, .nbytes, .destructor>,  'sqlite3_bind_text',  \
    sqliteBindText16, <.stmt, .index, .ptrText, .nbytes, .destructor>,  'sqlite3_bind_text16',  \
    sqliteBindValue, <.stmt, .index, .ptrValue>,  'sqlite3_bind_value',  \
    sqliteBindZeroblob, <.stmt, .index, .size>,  'sqlite3_bind_zeroblob',  \
    sqliteBlobBytes, <.hBlob>,  'sqlite3_blob_bytes',  \
    sqliteBlobClose, <.hBlob>,  'sqlite3_blob_close',  \
    sqliteBlobOpen, <.ptrDB, .DBname, .Table, .Column, .iRow, .flags, .ptrVarBlob>,  'sqlite3_blob_open',  \
    sqliteBlobRead, <.hBlob, .ptrBuffer, .bytes, .iOffset>,  'sqlite3_blob_read',  \
    sqliteBlobWrite, <.hBlob, .ptrBuffer, .bytes, .iOffset>,  'sqlite3_blob_write',  \
    sqliteBusyHandler, <.ptrDB, .ptrProc, .lParam>,  'sqlite3_busy_handler',  \
    sqliteBusyTimeout, <.ptrDB, .time_ms>,  'sqlite3_busy_timeout',  \
    sqliteChanges, <.ptrDB>,  'sqlite3_changes',  \
    sqliteClearBindings, <.stmt>,  'sqlite3_clear_bindings',  \
    sqliteClose, <.ptrDatabase>,  'sqlite3_close',  \
    sqliteCollationNeeded, <.ptrDB, .lparam, .ptrCallback>,  'sqlite3_collation_needed',  \
    sqliteCollationNeeded16, <.ptrDB, .lparam, .ptrCallback>,  'sqlite3_collation_needed16',  \
    sqliteColumnBlob, <.stmt, .iCol>,  'sqlite3_column_blob',  \
    sqliteColumnBytes, <.stmt, .iCol>,  'sqlite3_column_bytes',  \
    sqliteColumnBytes16, <.stmt, .iCol>,  'sqlite3_column_bytes16',  \
    sqliteColumnCount, <.stmt>,  'sqlite3_column_count',  \
    sqliteColumnDatabaseName, <.stmt, .index>,  'sqlite3_column_database_name',  \
    sqliteColumnDatabaseName16, <.stmt, .index>,  'sqlite3_column_database_name16',  \
    sqliteColumnDeclType, <.stmt, .index>,  'sqlite3_column_decltype',  \
    sqliteColumnDeclType16, <.stmt, .index>,  'sqlite3_column_decltype16',  \
    sqliteColumnDouble, <.stmt, .iCol>,  'sqlite3_column_double',  \
    sqliteColumnInt, <.stmt, .iCol>,  'sqlite3_column_int',  \
    sqliteColumnInt64, <.stmt, .iCol>,  'sqlite3_column_int64',  \
    sqliteColumnName, <.stmt, .index>,  'sqlite3_column_name',  \
    sqliteColumnName16, <.stmt, .index>,  'sqlite3_column_name16',  \
    sqliteColumnOriginName, <.stmt, .index>,  'sqlite3_column_origin_name',  \
    sqliteColumnOriginName16, <.stmt, .index>,  'sqlite3_column_origin_name16',  \
    sqliteColumnTableName, <.stmt, .index>,  'sqlite3_column_table_name',  \
    sqliteColumnTableName16, <.stmt, .index>,  'sqlite3_column_table_name16',  \
    sqliteColumnText, <.stmt, .iCol>,  'sqlite3_column_text',  \
    sqliteColumnText16, <.stmt, .iCol>,  'sqlite3_column_text16',  \
    sqliteColumnType, <.stmt, .iCol>,  'sqlite3_column_type',  \
    sqliteColumnValue, <.stmt, .iCol>,  'sqlite3_column_value',  \
    sqliteCommitHook, <.ptrDB, .ptrHook, .lparam>,  'sqlite3_commit_hook',  \
    sqliteCompileOptionGet, <.N>,  'sqlite3_compileoption_get',  \
    sqliteCompileOptionUsed, <.ptrOptName>,  'sqlite3_compileoption_used',  \
    sqliteComplete, <.ptrSQL>,  'sqlite3_complete',  \
    sqliteComplete16, <.ptrSQL>,  'sqlite3_complete16',  \
    sqliteConfig, <.index, ...>,  'sqlite3_config',  \
    sqliteContextDBHandle, <.context>,  'sqlite3_context_db_handle',  \
    sqliteCreateCollation, <.ptrDB, .ptrName, .eTextRep, .lparam, .procCompare>,  'sqlite3_create_collation',  \
    sqliteCreateCollation16, <.ptrDB, .ptrName, .eTextRep, .lparam, .procCompare>,  'sqlite3_create_collation16',  \
    sqliteCreateCollation_v2, <.ptrDB, .ptrName, .eTextRep, .lparam, .procCompare, .ptrDestroy>,  'sqlite3_create_collation_v2',  \
    sqliteCreateFunction, <.ptrDB, .ptrFunctionName, .nArg, .eTextRep, .lparam, .procFunc, .procStep, .procFinal>,  'sqlite3_create_function',  \
    sqliteCreateFunction16, <.ptrDB, .ptrFunctionName, .nArg, .eTextRep, .lparam, .procFunc, .procStep, .procFinal>,  'sqlite3_create_function16',  \
    sqliteCreateFunction_v2, <.ptrDB, .ptrFunctionName, .nArg, .eTextRep, .lparam, .procFunc, .procStep, .procFinal, .procDestroy,  \
      >,  'sqlite3_create_function_v2',  \
    sqliteCreateModule, <.ptrDB, .ptrModuleName, .ptrVTableModule, .lparam>,  'sqlite3_create_module',  \
    sqliteCreateModule_v2, <.ptrDB, .ptrModuleName, .ptrVTableModule, .lparam, .procDestroy>,  'sqlite3_create_module_v2',  \
    sqliteDBConfig, <.ptrDB, .index, ...>,  'sqlite3_db_config',  \
    sqliteDBHandle, <.stmt>,  'sqlite3_db_handle',  \
    sqliteDBMutex, <.ptrDB>,  'sqlite3_db_mutex',  \
    sqliteDBStatus, <.ptrDB, .index, .ptrRetCurrent, .ptrRetHighest, .flagReset>,  'sqlite3_db_status',  \
    sqliteDataCount, <.stmt>,  'sqlite3_data_count',  \
    sqliteDeclareVtab, <.ptrDB, .ptrSQL>,  'sqlite3_declare_vtab',  \
    sqliteEnableLoadExtension, <.ptrDB, .flagEnable>,  'sqlite3_enable_load_extension',  \
    sqliteEnableSharedCache, <.flagEnable>,  'sqlite3_enable_shared_cache',  \
    sqliteErrCode, <.ptrDB>,  'sqlite3_errcode',  \
    sqliteErrMsg, <.ptrDB>,  'sqlite3_errmsg',  \
    sqliteErrMsg16, <.ptrDB>,  'sqlite3_errmsg16',  \
    sqliteExec, <.ptrDB, .ptrSQL, .procCallback, .lparam, .ptrVarErrMsg>,  'sqlite3_exec',  \
    sqliteExpired, <VOID>,  'sqlite3_expired',  \
    sqliteExtendedErrCode, <.ptrDB>,  'sqlite3_extended_errcode',  \
    sqliteExtendedResultCodes, <.ptrDB, .flagEnable>,  'sqlite3_extended_result_codes',  \
    sqliteFileControl, <.ptrDB, .ptrDBName, .wparam, .lparam>,  'sqlite3_file_control',  \
    sqliteFinalize, <.stmt>,  'sqlite3_finalize',  \
    sqliteFree, <.ptrmem>,  'sqlite3_free',  \
    sqliteFreeTable, <.ptrVarResult>,  'sqlite3_free_table',  \
    sqliteGetAutocommit, <.ptrDB>,  'sqlite3_get_autocommit',  \
    sqliteGetAuxdata, <.context, .N>,  'sqlite3_get_auxdata',  \
    sqliteGetTable, <.ptrDB, .ptrSQL, .ptrVarResult, .ptrVarRows, .ptrVarColumns, .ptrVarErrorMsg>,  'sqlite3_get_table',  \
    sqliteGlobalRecover_OLD, <VOID>,  'sqlite3_global_recover',  \
    sqliteInitialize, <VOID>,  'sqlite3_initialize',  \
    sqliteInterrupt, <.ptrDB>,  'sqlite3_interrupt',  \
    sqliteLastInsertRowID, <.ptrDB>,  'sqlite3_last_insert_rowid',  \
    sqliteLibVersion, <VOID>,  'sqlite3_libversion',  \
    sqliteLibversionNumber, <VOID>,  'sqlite3_libversion_number',  \
    sqliteLimit, <.ptrDB, .idLimit, .newVal>,  'sqlite3_limit',  \
    sqliteLoadExtension, <.ptrDB, .nameDLL, .entryProc, .ptrVarErrMsg>,  'sqlite3_load_extension',  \
    sqliteLog, <.iErrCode, .ptrFormat, ...>,  'sqlite3_log',  \
    sqliteMAlloc, <.size>,  'sqlite3_malloc',  \
    sqliteMemoryAlarm_OLD, <VOID>,  'sqlite3_memory_alarm',  \
    sqliteMemoryHighWater, <.flagReset>,  'sqlite3_memory_highwater',  \
    sqliteMemoryUsed, <VOID>,  'sqlite3_memory_used',  \
    sqliteMprintf, <.ptrString, ...>,  'sqlite3_mprintf',  \
    sqliteMutexAlloc, <.type>,  'sqlite3_mutex_alloc',  \
    sqliteMutexEnter, <.hMutex>,  'sqlite3_mutex_enter',  \
    sqliteMutexFree, <.hMutex>,  'sqlite3_mutex_free',  \
    sqliteMutexLeave, <.hMutex>,  'sqlite3_mutex_leave',  \
    sqliteMutexTry, <.hMutex>,  'sqlite3_mutex_try',  \
    sqliteNextStmt, <.ptrDB, .stmt>,  'sqlite3_next_stmt',  \
    sqliteOSEnd, <VOID>,  'sqlite3_os_end',  \
    sqliteOSInit, <VOID>,  'sqlite3_os_init',  \
    sqliteOpen, <.ptrFileName, .ptrVarDB>,  'sqlite3_open',  \
    sqliteOpen16, <.ptrFileName, .ptrVarDB>,  'sqlite3_open16',  \
    sqliteOpen_v2, <.ptrFileName, .ptrVarDB, .flags, .ptrVFSName>,  'sqlite3_open_v2',  \
    sqliteOverloadFunction, <.ptrDB, .ptrFuncName, .lparam>,  'sqlite3_overload_function',  \
    sqlitePrepare, <.ptrDB, .ptrSQL, .lenSQL, .ptrVarStmt, .ptrVarNext>,  'sqlite3_prepare',  \
    sqlitePrepare16, <.ptrDB, .ptrSQL, .lenSQL, .ptrVarStmt, .ptrVarNext>,  'sqlite3_prepare16',  \
    sqlitePrepare16_v2, <.ptrDB, .ptrSQL, .lenSQL, .ptrVarStmt, .ptrVarNext>,  'sqlite3_prepare16_v2',  \
    sqlitePrepare_v2, <.ptrDB, .ptrSQL, .lenSQL, .ptrVarStmt, .ptrVarNext>,  'sqlite3_prepare_v2',  \
    sqliteProfile, <.ptrDB, .procProfiler, .lparam>,  'sqlite3_profile',  \
    sqliteProgressHandler, <.ptrDB, .N, .procProgress, .lparam>,  'sqlite3_progress_handler',  \
    sqliteRandomness, <.bytes, .buffer>,  'sqlite3_randomness',  \
    sqliteReAlloc, <.ptrmem, .newsize>,  'sqlite3_realloc',  \
    sqliteReleaseMemory, <.bytes>,  'sqlite3_release_memory',  \
    sqliteReset, <.stmt>,  'sqlite3_reset',  \
    sqliteResetAutoExtension, <VOID>,  'sqlite3_reset_auto_extension',  \
    sqliteResultBlob, <.context, .ptrdata, .size, .procDestroy>,  'sqlite3_result_blob',  \
    sqliteResultDouble, <.context, .double>,  'sqlite3_result_double',  \
    sqliteResultError, <.context, .ptrErrMsg, .size>,  'sqlite3_result_error',  \
    sqliteResultError16, <.context, .ptrErrMsg, .size>,  'sqlite3_result_error16',  \
    sqliteResultErrorCode, <.context, .errcode>,  'sqlite3_result_error_code',  \
    sqliteResultErrorNoMem, <.context>,  'sqlite3_result_error_nomem',  \
    sqliteResultErrorTooBig, <.context>,  'sqlite3_result_error_toobig',  \
    sqliteResultInt, <.context, .integer>,  'sqlite3_result_int',  \
    sqliteResultInt64, <.context, .int64Lo, .int64Hi>,  'sqlite3_result_int64',  \
    sqliteResultNULL, <.context>,  'sqlite3_result_null',  \
    sqliteResultText, <.context, .ptrText, .size, .procDestroy>,  'sqlite3_result_text',  \
    sqliteResultText16, <.context, .ptrText, .size, .procDestroy>,  'sqlite3_result_text16',  \
    sqliteResultText16be, <.context, .ptrText, .size, .procDestroy>,  'sqlite3_result_text16be',  \
    sqliteResultText16le, <.context, .ptrText, .size, .procDestroy>,  'sqlite3_result_text16le',  \
    sqliteResultValue, <.context, .ptrValue>,  'sqlite3_result_value',  \
    sqliteResultZeroBlob, <.context, .size>,  'sqlite3_result_zeroblob',  \
    sqliteRollbackHook, <.ptrDB, .ptrHook, .lparam>,  'sqlite3_rollback_hook',  \
    sqliteRtreeGeometryCallback, <NONE>,  'sqlite3_rtree_geometry_callback',  \
    sqliteSQL, <.stmt>,  'sqlite3_sql',  \
    sqliteSetAuthorizer, <.ptrDB, .procAuthorizer, .lparam>,  'sqlite3_set_authorizer',  \
    sqliteSetAuxdata, <.context, .N, .ptrData, .procDestructor>,  'sqlite3_set_auxdata',  \
    sqliteShutdown, <VOID>,  'sqlite3_shutdown',  \
    sqliteSleep, <.sleep_ms>,  'sqlite3_sleep',  \
    sqliteSnprintf, <.size, .ptrBuffer, .ptrString, ...>,  'sqlite3_snprintf',  \
    sqliteSoftHeapLimit, <.N>,  'sqlite3_soft_heap_limit',  \
    sqliteSoftHeapLimit64, <.sizeLo, .sizeHi>,  'sqlite3_soft_heap_limit64',  \
    sqliteSourceID, <VOID>,  'sqlite3_sourceid',  \
    sqliteStatus, <.paramIndex, .ptrVarResult, .ptrVarHighwater, .flagReset>,  'sqlite3_status',  \
    sqliteStep, <.stmt>,  'sqlite3_step',  \
    sqliteStmtStatus, <.stmt, .paramIndex, .flagReset>,  'sqlite3_stmt_status',  \
    sqliteStrnicmp, <.ptrStr1, .ptrStr2, .size>,  'sqlite3_strnicmp',  \
    sqliteTableColumnMetadata, <.ptrDB, .ptrDBName, .ptrTableName, .ptrColumnName, .ptrVarDataType, .ptrVarCollSeq, .ptrVarNotNull,  \
        .ptrVarPrimaryKey, .ptrVarAutoInc>,  'sqlite3_table_column_metadata',  \
    sqliteTestControl, <.opCode, ...>,  'sqlite3_test_control',  \
    sqliteThreadCleanup, <VOID>,  'sqlite3_thread_cleanup',  \
    sqliteThreadsafe, <VOID>,  'sqlite3_threadsafe',  \
    sqliteTotalChanges, <.ptrDB>,  'sqlite3_total_changes',  \
    sqliteTrace, <.ptrDB, .procTrace, .lparam>,  'sqlite3_trace',  \
    sqliteTransferBindings, <VOID>,  'sqlite3_transfer_bindings',  \
    sqliteUpdateHook, <.ptrDB, .procUpdateHook, .lparam>,  'sqlite3_update_hook',  \
    sqliteUserData, <.context>,  'sqlite3_user_data',  \
    sqliteValueBlob, <.ptrValue>,  'sqlite3_value_blob',  \
    sqliteValueBytes, <.ptrValue>,  'sqlite3_value_bytes',  \
    sqliteValueBytes16, <.ptrValue>,  'sqlite3_value_bytes16',  \
    sqliteValueDouble, <.ptrValue>,  'sqlite3_value_double',  \
    sqliteValueInt, <.ptrValue>,  'sqlite3_value_int',  \
    sqliteValueInt64, <.ptrValue>,  'sqlite3_value_int64',  \
    sqliteValueNumericType, <.ptrValue>,  'sqlite3_value_numeric_type',  \
    sqliteValueText, <.ptrValue>,  'sqlite3_value_text',  \
    sqliteValueText16, <.ptrValue>,  'sqlite3_value_text16',  \
    sqliteValueText16be, <.ptrValue>,  'sqlite3_value_text16be',  \
    sqliteValueText16le, <.ptrValue>,  'sqlite3_value_text16le',  \
    sqliteValueType, <.ptrValue>,  'sqlite3_value_type',  \
    sqliteVersion, <VOID>,  'sqlite3_version',  \
    sqliteVfsFind, <.ptrVFSName>,  'sqlite3_vfs_find',  \
    sqliteVfsRegister, <.hVFS, .flagDefault>,  'sqlite3_vfs_register',  \
    sqliteVfsUnregister, <.hVFS>,  'sqlite3_vfs_unregister',  \
    sqliteVmprintf, <.ptrString, .va_list>,  'sqlite3_vmprintf',  \
    sqliteWalAutocheckpoint, <.ptrDB, .N>,  'sqlite3_wal_autocheckpoint',  \
    sqliteWalCheckpoint, <.ptrDB, .ptrDBName>,  'sqlite3_wal_checkpoint',  \
    sqliteWalHook, <.ptrDB, .procCommitHook, .lparam>,  'sqlite3_wal_hook',  \
    sqliteWin32_MbcsToUtf8, <NONE>,  'sqlite3_win32_mbcs_to_utf8'
