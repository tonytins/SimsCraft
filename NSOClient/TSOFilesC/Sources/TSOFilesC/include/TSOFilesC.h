#ifndef TSOFILES_C_H
#define TSOFILES_C_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct TSOFilesCArchive TSOFilesCArchive;
typedef struct TSOFilesCFAR1Archive TSOFilesCFAR1Archive;
typedef struct TSOFilesCFAR3Archive TSOFilesCFAR3Archive;

typedef enum TSOFilesCStatus {
    TSOFILES_C_OK = 0,
    TSOFILES_C_INVALID_ARGUMENT = 1,
    TSOFILES_C_REFPACK_TRUNCATED_INPUT = 2,
    TSOFILES_C_REFPACK_INVALID_BACK_REFERENCE = 3,
    TSOFILES_C_DBPF_NOT_ARCHIVE = 4,
    TSOFILES_C_DBPF_TRUNCATED = 5,
    TSOFILES_C_ENTRY_OUT_OF_BOUNDS = 6,
    TSOFILES_C_DBPF_ENTRY_OUT_OF_BOUNDS = TSOFILES_C_ENTRY_OUT_OF_BOUNDS,
    TSOFILES_C_NOT_FOUND = 7,
    TSOFILES_C_OUT_OF_RANGE = 8,
    TSOFILES_C_FAR1_NOT_ARCHIVE = 9,
    TSOFILES_C_FAR1_TRUNCATED = 10,
    TSOFILES_C_FAR3_NOT_ARCHIVE = 11,
    TSOFILES_C_FAR3_TRUNCATED = 12,
    TSOFILES_C_FAR3_DECOMPRESSION_FAILED = 13
} TSOFilesCStatus;

/*
 * Decompresses a RefPack stream. The output is allocated by this library and
 * must be released with buffer_free. A zero-length output is NULL.
 * Input and output sizes are signed 64-bit byte counts and must be nonnegative.
 */
int32_t refpack_decompress(
    const uint8_t *compressed,
    int64_t compressed_size,
    int64_t decompressed_size,
    uint8_t **output,
    int64_t *output_size
);

/* Releases a byte buffer returned by a data or entry-name function.
 * Passing NULL is allowed. */
void buffer_free(uint8_t *buffer);

/*
 * Opens a DBPF archive from memory. The archive copies/retains its own data,
 * so the input buffer can be released after this call. Release the returned
 * archive with dbpf_close.
 */
int32_t dbpf_open(
    const uint8_t *bytes,
    int64_t byte_count,
    TSOFilesCArchive **archive
);

/* Releases an archive returned by dbpf_open. Passing NULL is allowed. */
void dbpf_close(TSOFilesCArchive *archive);

/* Writes the archive version to the provided outputs. */
int32_t dbpf_version(
    const TSOFilesCArchive *archive,
    uint32_t *major_version,
    uint32_t *minor_version
);

/* Writes the number of entries in the archive. */
int32_t dbpf_entry_count(const TSOFilesCArchive *archive, int64_t *count);

/*
 * Reads the metadata for an entry by its zero-based index. Entries are in
 * archive index order.
 */
int32_t dbpf_entry_at(
    const TSOFilesCArchive *archive,
    int64_t index,
    uint32_t *type_id,
    uint32_t *group_id,
    uint32_t *instance_id,
    uint32_t *file_offset,
    uint32_t *file_size
);

/* Finds the first entry matching its instance and type IDs. */
int32_t dbpf_find_entry(
    const TSOFilesCArchive *archive,
    uint32_t instance_id,
    uint32_t type_id,
    int64_t *index
);

/* Copies an entry's contents into a library-allocated buffer. */
int32_t dbpf_entry_data(
    const TSOFilesCArchive *archive,
    int64_t index,
    uint8_t **data,
    int64_t *data_size
);

/*
 * Opens a FAR1 archive. variant is 0 for FAR1a and 1 for FAR1b.
 * The returned archive must be released with far1_close.
 */
int32_t far1_open(
    const uint8_t *bytes,
    int64_t byte_count,
    int32_t variant,
    TSOFilesCFAR1Archive **archive
);

void far1_close(TSOFilesCFAR1Archive *archive);
int32_t far1_entry_count(const TSOFilesCFAR1Archive *archive, int64_t *count);
int32_t far1_entry_at(
    const TSOFilesCFAR1Archive *archive,
    int64_t index,
    int64_t *data_length,
    int64_t *compressed_length,
    int64_t *data_offset
);
int32_t far1_find_entry(
    const TSOFilesCFAR1Archive *archive,
    const uint8_t *name,
    int64_t name_size,
    int64_t *index
);
/* Entry-name buffers contain UTF-8 bytes without a trailing NUL. Free with
 * buffer_free. */
int32_t far1_entry_name(
    const TSOFilesCFAR1Archive *archive,
    int64_t index,
    uint8_t **name,
    int64_t *name_size
);
int32_t far1_entry_data(
    const TSOFilesCFAR1Archive *archive,
    int64_t index,
    uint8_t **data,
    int64_t *data_size
);

/*
 * Opens a FAR3 archive. The returned archive must be released with
 * far3_close.
 */
int32_t far3_open(const uint8_t *bytes, int64_t byte_count, TSOFilesCFAR3Archive **archive);
void far3_close(TSOFilesCFAR3Archive *archive);
int32_t far3_entry_count(const TSOFilesCFAR3Archive *archive, int64_t *count);
int32_t far3_entry_at(
    const TSOFilesCFAR3Archive *archive,
    int64_t index,
    uint32_t *file_id,
    uint32_t *type_id,
    uint32_t *decompressed_size,
    uint32_t *compressed_size,
    uint8_t *data_type,
    uint32_t *data_offset,
    uint8_t *compression_flag,
    uint8_t *access_count
);
int32_t far3_find_entry_by_name(
    const TSOFilesCFAR3Archive *archive,
    const uint8_t *name,
    int64_t name_size,
    int64_t *index
);
int32_t far3_find_entry_by_asset_id(
    const TSOFilesCFAR3Archive *archive,
    uint32_t file_id,
    uint32_t type_id,
    int64_t *index
);
/* Entry-name buffers contain UTF-8 bytes without a trailing NUL. Free with
 * buffer_free. */
int32_t far3_entry_name(
    const TSOFilesCFAR3Archive *archive,
    int64_t index,
    uint8_t **name,
    int64_t *name_size
);
int32_t far3_entry_data(
    const TSOFilesCFAR3Archive *archive,
    int64_t index,
    uint8_t **data,
    int64_t *data_size
);

#ifdef __cplusplus
}
#endif

#endif
