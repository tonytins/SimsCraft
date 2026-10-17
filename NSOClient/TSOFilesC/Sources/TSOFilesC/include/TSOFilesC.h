#ifndef TSOFILES_C_H
#define TSOFILES_C_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct TSOFilesCArchive TSOFilesCArchive;

typedef enum TSOFilesCStatus {
    TSOFILES_C_OK = 0,
    TSOFILES_C_INVALID_ARGUMENT = 1,
    TSOFILES_C_REFPACK_TRUNCATED_INPUT = 2,
    TSOFILES_C_REFPACK_INVALID_BACK_REFERENCE = 3,
    TSOFILES_C_DBPF_NOT_ARCHIVE = 4,
    TSOFILES_C_DBPF_TRUNCATED = 5,
    TSOFILES_C_DBPF_ENTRY_OUT_OF_BOUNDS = 6,
    TSOFILES_C_NOT_FOUND = 7,
    TSOFILES_C_OUT_OF_RANGE = 8
} TSOFilesCStatus;

/*
 * Decompresses a RefPack stream. The output is allocated by this library and
 * must be released with tsofiles_c_buffer_free. A zero-length output is NULL.
 * Input and output sizes are signed 64-bit byte counts and must be nonnegative.
 */
int32_t tsofiles_c_refpack_decompress(
    const uint8_t *compressed,
    int64_t compressed_size,
    int64_t decompressed_size,
    uint8_t **output,
    int64_t *output_size
);

/* Releases a byte buffer returned by tsofiles_c_refpack_decompress or
 * tsofiles_c_dbpf_entry_data. Passing NULL is allowed. */
void tsofiles_c_buffer_free(uint8_t *buffer);

/*
 * Opens a DBPF archive from memory. The archive copies/retains its own data,
 * so the input buffer can be released after this call. Release the returned
 * archive with tsofiles_c_dbpf_close.
 */
int32_t tsofiles_c_dbpf_open(
    const uint8_t *bytes,
    int64_t byte_count,
    TSOFilesCArchive **archive
);

/* Releases an archive returned by tsofiles_c_dbpf_open. Passing NULL is allowed. */
void tsofiles_c_dbpf_close(TSOFilesCArchive *archive);

/* Writes the archive version to the provided outputs. */
int32_t tsofiles_c_dbpf_version(
    const TSOFilesCArchive *archive,
    uint32_t *major_version,
    uint32_t *minor_version
);

/* Writes the number of entries in the archive. */
int32_t tsofiles_c_dbpf_entry_count(const TSOFilesCArchive *archive, int64_t *count);

/*
 * Reads the metadata for an entry by its zero-based index. Entries are in
 * archive index order.
 */
int32_t tsofiles_c_dbpf_entry_at(
    const TSOFilesCArchive *archive,
    int64_t index,
    uint32_t *type_id,
    uint32_t *group_id,
    uint32_t *instance_id,
    uint32_t *file_offset,
    uint32_t *file_size
);

/* Finds the first entry matching its instance and type IDs. */
int32_t tsofiles_c_dbpf_find_entry(
    const TSOFilesCArchive *archive,
    uint32_t instance_id,
    uint32_t type_id,
    int64_t *index
);

/* Copies an entry's contents into a library-allocated buffer. */
int32_t tsofiles_c_dbpf_entry_data(
    const TSOFilesCArchive *archive,
    int64_t index,
    uint8_t **data,
    int64_t *data_size
);

#ifdef __cplusplus
}
#endif

#endif
