#include "TSOFilesC.h"

#include <stddef.h>

extern int32_t tsofiles_swift_refpack_decompress(
    const uint8_t *compressed,
    int64_t compressed_size,
    int64_t decompressed_size,
    uint8_t **output,
    int64_t *output_size
);
extern void tsofiles_swift_buffer_free(uint8_t *buffer);
extern int32_t tsofiles_swift_dbpf_open(const uint8_t *bytes, int64_t byte_count, void **archive);
extern void tsofiles_swift_dbpf_close(void *archive);
extern int32_t tsofiles_swift_dbpf_version(const void *archive, uint32_t *major_version, uint32_t *minor_version);
extern int32_t tsofiles_swift_dbpf_entry_count(const void *archive, int64_t *count);
extern int32_t tsofiles_swift_dbpf_entry_at(
    const void *archive,
    int64_t index,
    uint32_t *type_id,
    uint32_t *group_id,
    uint32_t *instance_id,
    uint32_t *file_offset,
    uint32_t *file_size
);
extern int32_t tsofiles_swift_dbpf_find_entry(
    const void *archive,
    uint32_t instance_id,
    uint32_t type_id,
    int64_t *index
);
extern int32_t tsofiles_swift_dbpf_entry_data(
    const void *archive,
    int64_t index,
    uint8_t **data,
    int64_t *data_size
);

int32_t tsofiles_c_refpack_decompress(
    const uint8_t *compressed,
    int64_t compressed_size,
    int64_t decompressed_size,
    uint8_t **output,
    int64_t *output_size
) {
    return tsofiles_swift_refpack_decompress(compressed, compressed_size, decompressed_size, output, output_size);
}

void tsofiles_c_buffer_free(uint8_t *buffer) {
    tsofiles_swift_buffer_free(buffer);
}

int32_t tsofiles_c_dbpf_open(const uint8_t *bytes, int64_t byte_count, TSOFilesCArchive **archive) {
    if (archive == NULL) {
        return TSOFILES_C_INVALID_ARGUMENT;
    }
    *archive = NULL;
    void *storage = NULL;
    int32_t status = tsofiles_swift_dbpf_open(bytes, byte_count, &storage);
    if (status == TSOFILES_C_OK) {
        *archive = (TSOFilesCArchive *)storage;
    }
    return status;
}

void tsofiles_c_dbpf_close(TSOFilesCArchive *archive) {
    tsofiles_swift_dbpf_close(archive);
}

int32_t tsofiles_c_dbpf_version(
    const TSOFilesCArchive *archive,
    uint32_t *major_version,
    uint32_t *minor_version
) {
    return tsofiles_swift_dbpf_version(archive, major_version, minor_version);
}

int32_t tsofiles_c_dbpf_entry_count(const TSOFilesCArchive *archive, int64_t *count) {
    return tsofiles_swift_dbpf_entry_count(archive, count);
}

int32_t tsofiles_c_dbpf_entry_at(
    const TSOFilesCArchive *archive,
    int64_t index,
    uint32_t *type_id,
    uint32_t *group_id,
    uint32_t *instance_id,
    uint32_t *file_offset,
    uint32_t *file_size
) {
    return tsofiles_swift_dbpf_entry_at(
        archive, index, type_id, group_id, instance_id, file_offset, file_size);
}

int32_t tsofiles_c_dbpf_find_entry(
    const TSOFilesCArchive *archive,
    uint32_t instance_id,
    uint32_t type_id,
    int64_t *index
) {
    return tsofiles_swift_dbpf_find_entry(archive, instance_id, type_id, index);
}

int32_t tsofiles_c_dbpf_entry_data(
    const TSOFilesCArchive *archive,
    int64_t index,
    uint8_t **data,
    int64_t *data_size
) {
    return tsofiles_swift_dbpf_entry_data(archive, index, data, data_size);
}
