/**************************************************************
 *
 * userprog/ksyscall.h
 *
 * Kernel interface for systemcalls
 *
 * by Marcus Voelp  (c) Universitaet Karlsruhe
 *
 **************************************************************/

#ifndef __USERPROG_KSYSCALL_H__
#define __USERPROG_KSYSCALL_H__

#include "kernel.h"
#include "synchconsole.h"

void SysHalt() {
    kernel->interrupt->Halt();
}

void SysPrintInt(int val) {
    DEBUG(dbgTraCode, "In ksyscall.h:SysPrintInt, into synchConsoleOut->PutInt, " << kernel->stats->totalTicks);
    kernel->synchConsoleOut->PutInt(val);
    DEBUG(dbgTraCode, "In ksyscall.h:SysPrintInt, return from synchConsoleOut->PutInt, " << kernel->stats->totalTicks);
}

int SysAdd(int op1, int op2) {
    return op1 + op2;
}

int SysCreate(char *filename) {
    // return value
    // 1: success
    // 0: failed
    return kernel->fileSystem->Create(filename);
}

/*  HW1 實作：檔案描述符管理表 (File Descriptor Table)*/


// 最大同時開啟檔案數量 / Maximum number of concurrently open files
#define MAX_OPEN_FILES 20

// 核心檔案描述符陣列，存放 OpenFile 物件指標
// File descriptor array storing pointers to OpenFile objects
static OpenFile* fileDescriptorTable[MAX_OPEN_FILES] = { NULL };

/* ---------------- 開啟檔案 (Open System Call) ---------------- */
inline OpenFileId SysOpen(char *name) {
    // 參數合法性檢查 / Validate input pointer
    if (name == NULL) {
        return -1;
    }

    // 呼叫底層檔案系統開啟檔案，取得實體物件指標
    // Open file via underlying file system to get OpenFile object pointer
    OpenFile *file = kernel->fileSystem->Open(name);
    if (file == NULL) {
        return -1; // 檔案不存在或開啟失敗 / File does not exist or open failed
    }

    // 尋找空閒的 Descriptor 欄位 (索引 0 保留，從 1 開始分配)
    // Find an empty slot in the table (index 0 is reserved, allocate from 1)
    for (int i = 1; i < MAX_OPEN_FILES; i++) {
        if (fileDescriptorTable[i] == NULL) {
            fileDescriptorTable[i] = file; // 登記指標 / Store pointer
            return i;                      // 回傳陣列索引作為 OpenFileId / Return index as OpenFileId
        }
    }

    // 映射表已滿，釋放資源避免記憶體洩漏 / Table is full; free object to prevent memory leak
    delete file;
    return -1;
}

/* ---------------- 寫入檔案 (Write System Call) ---------------- */
inline int SysWrite(char *buffer, int size, OpenFileId id) {
    // 檢查 ID 範圍、指標是否有效及緩衝區合法性
    // Validate file descriptor range, existence of file, and buffer pointer
    if (id < 1 || id >= MAX_OPEN_FILES || fileDescriptorTable[id] == NULL || buffer == NULL || size < 0) {
        return -1; // 錯誤操作 / Invalid operation
    }

    // 透過 OpenFile 物件寫入資料，回傳實際寫入的 byte 數
    // Write data via OpenFile object; returns actual bytes written
    return fileDescriptorTable[id]->Write(buffer, size);
}

/* ---------------- 讀取檔案 (Read System Call) ---------------- */
inline int SysRead(char *buffer, int size, OpenFileId id) {
    // 檢查 ID 範圍、指標是否有效及緩衝區合法性
    // Validate file descriptor range, existence of file, and buffer pointer
    if (id < 1 || id >= MAX_OPEN_FILES || fileDescriptorTable[id] == NULL || buffer == NULL || size < 0) {
        return -1; // 錯誤操作 / Invalid operation
    }

    // 透過 OpenFile 物件讀取資料，回傳實際讀取的 byte 數
    // Read data via OpenFile object; returns actual bytes read
    return fileDescriptorTable[id]->Read(buffer, size);
}

/* ---------------- 關閉檔案 (Close System Call) ---------------- */
inline int SysClose(OpenFileId id) {
    // 檢查目標檔案是否存在於映射表中
    // Check if the target file descriptor exists in the table
    if (id < 1 || id >= MAX_OPEN_FILES || fileDescriptorTable[id] == NULL) {
        return -1; // 失敗 (無效 ID) / Failure (invalid ID)
    }

    // 呼叫解構子關閉底層檔案並釋放記憶體
    // Invoke destructor to close underlying file and free memory
    delete fileDescriptorTable[id];

    // 清空欄位以供後續重複利用 / Clear slot for future reuse
    fileDescriptorTable[id] = NULL;

    return 1; // 成功 / Success
}

// When you finish the function "OpenAFile", you can remove the comment below.
/*
OpenFileId SysOpen(char *name)
{
        return kernel->fileSystem->OpenAFile(name);
}
*/
#endif /* ! __USERPROG_KSYSCALL_H__ */
