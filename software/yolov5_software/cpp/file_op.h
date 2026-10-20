// file_ops.h

#ifndef FILE_OPS_H
#define FILE_OPS_H

#include <stddef.h>
#include <stdint.h>

// 定义错误码
#define FILE_OP_SUCCESS 0
#define FILE_OP_FAILURE -1

// 函数声明
int load_file(const char *filename, void *buffer, size_t size)
{
    FILE *file = fopen(filename, "rb");
    if (!file)
    {
        perror("Error opening file for reading");
        return FILE_OP_FAILURE;
    }

    size_t read_size = fread(buffer, 1, size, file);
    if (read_size != size)
    {
        perror("Error reading file");
        fclose(file);
        return FILE_OP_FAILURE;
    }

    fclose(file);
    return FILE_OP_SUCCESS;
}

int save_file(const char *filename, void *buffer, size_t size)
{
    FILE *file = fopen(filename, "wb");
    if (!file)
    {
        perror("Error opening file for writing");
        return FILE_OP_FAILURE;
    }

    size_t written_size = fwrite(buffer, 1, size, file);
    if (written_size != size)
    {
        perror("Error writing file");
        fclose(file);
        return FILE_OP_FAILURE;
    }

    fclose(file);
    return FILE_OP_SUCCESS;
}

#endif // FILE_OPS_H
