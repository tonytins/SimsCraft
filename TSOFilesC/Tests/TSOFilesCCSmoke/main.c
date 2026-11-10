#include <TSOFilesC.h>

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define CHECK(condition) \
    do { \
        if (!(condition)) { \
            fprintf(stderr, "check failed at %s:%d: %s\n", __FILE__, __LINE__, #condition); \
            goto cleanup; \
        } \
    } while (0)

static void write_u32_le(uint8_t *bytes, size_t offset, uint32_t value) {
    bytes[offset] = (uint8_t)value;
    bytes[offset + 1] = (uint8_t)(value >> 8);
    bytes[offset + 2] = (uint8_t)(value >> 16);
    bytes[offset + 3] = (uint8_t)(value >> 24);
}

static void write_u16_le(uint8_t *bytes, size_t offset, uint16_t value) {
    bytes[offset] = (uint8_t)value;
    bytes[offset + 1] = (uint8_t)(value >> 8);
}

static bool test_refpack(void) {
    const uint8_t compressed[] = {0x0E, 0x01, 0x61, 0x62, 0xFC, 0x00, 0x00};
    uint8_t *output = NULL;
    int64_t output_size = 0;
    bool succeeded = false;

    const int32_t status = refpack_decompress(
        compressed, (int64_t)sizeof(compressed), 8, &output, &output_size);
    CHECK(status == TSOFILES_C_OK);
    CHECK(output_size == 8);
    CHECK(output != NULL);
    CHECK(output[0] == 'a' && output[1] == 'b' && output[7] == 'b');
    succeeded = true;

cleanup:
    buffer_free(output);
    return succeeded;
}

static bool test_dbpf(void) {
    uint8_t dbpf[71] = {'D', 'B', 'P', 'F'};
    write_u32_le(dbpf, 4, 1);
    write_u32_le(dbpf, 8, 0);
    write_u32_le(dbpf, 24, 1000);
    write_u32_le(dbpf, 28, 2000);
    write_u32_le(dbpf, 32, 7);
    write_u32_le(dbpf, 36, 1);
    write_u32_le(dbpf, 40, 51);
    write_u32_le(dbpf, 44, 20);
    dbpf[48] = 'S';
    dbpf[49] = 'F';
    dbpf[50] = 'X';
    write_u32_le(dbpf, 51, 0x1D07EB4B);
    write_u32_le(dbpf, 55, 0x9DBDBF89);
    write_u32_le(dbpf, 59, 12);
    write_u32_le(dbpf, 63, 48);
    write_u32_le(dbpf, 67, 3);

    const uint8_t not_dbpf[] = {'N', 'O', 'P', 'E'};
    TSOFilesCArchive *archive = NULL;
    uint8_t *entry_data = NULL;
    bool succeeded = false;
    int64_t entry_data_size = 0;

    int32_t status = dbpf_open(dbpf, (int64_t)sizeof(dbpf), &archive);
    CHECK(status == TSOFILES_C_OK);
    CHECK(archive != NULL);

    uint32_t major_version = 0;
    uint32_t minor_version = 0;
    CHECK(dbpf_version(archive, &major_version, &minor_version) == TSOFILES_C_OK);
    CHECK(major_version == 1 && minor_version == 0);

    int64_t entry_count = 0;
    CHECK(dbpf_entry_count(archive, &entry_count) == TSOFILES_C_OK);
    CHECK(entry_count == 1);

    int64_t entry_index = -1;
    CHECK(dbpf_find_entry(archive, 12, 0x1D07EB4B, &entry_index) == TSOFILES_C_OK);
    CHECK(entry_index == 0);

    uint32_t type_id = 0;
    uint32_t group_id = 0;
    uint32_t instance_id = 0;
    uint32_t file_offset = 0;
    uint32_t file_size = 0;
    CHECK(dbpf_entry_at(
        archive, entry_index, &type_id, &group_id, &instance_id, &file_offset, &file_size) == TSOFILES_C_OK);
    CHECK(type_id == 0x1D07EB4B && group_id == 0x9DBDBF89);
    CHECK(instance_id == 12 && file_offset == 48 && file_size == 3);

    CHECK(dbpf_entry_data(archive, entry_index, &entry_data, &entry_data_size) == TSOFILES_C_OK);
    CHECK(entry_data_size == 3);
    CHECK(entry_data != NULL);
    CHECK(entry_data[0] == 'S' && entry_data[1] == 'F' && entry_data[2] == 'X');
    buffer_free(entry_data);
    entry_data = NULL;
    dbpf_close(archive);
    archive = NULL;

    status = dbpf_open(not_dbpf, (int64_t)sizeof(not_dbpf), &archive);
    CHECK(status == TSOFILES_C_DBPF_NOT_ARCHIVE);
    CHECK(archive == NULL);
    succeeded = true;

cleanup:
    buffer_free(entry_data);
    dbpf_close(archive);
    return succeeded;
}

static bool test_far1(void) {
    uint8_t far1_bytes[48] = {'F', 'A', 'R', '!', 'b', 'y', 'A', 'Z'};
    write_u32_le(far1_bytes, 8, 1);
    write_u32_le(far1_bytes, 12, 21);
    far1_bytes[16] = 'C';
    far1_bytes[17] = 'H';
    far1_bytes[18] = 'A';
    far1_bytes[19] = 'I';
    far1_bytes[20] = 'R';
    write_u32_le(far1_bytes, 21, 1);
    write_u32_le(far1_bytes, 25, 5);
    write_u32_le(far1_bytes, 29, 5);
    write_u32_le(far1_bytes, 33, 16);
    write_u16_le(far1_bytes, 37, 9);
    const uint8_t far1_name[] = "chair.iff";
    for (size_t index = 0; index < sizeof(far1_name) - 1; index++) {
        far1_bytes[39 + index] = far1_name[index];
    }

    TSOFilesCFAR1Archive *archive = NULL;
    uint8_t *name_data = NULL;
    uint8_t *entry_data = NULL;
    bool succeeded = false;
    int32_t status = far1_open(far1_bytes, (int64_t)sizeof(far1_bytes), 1, &archive);
    CHECK(status == TSOFILES_C_OK);
    CHECK(archive != NULL);

    int64_t entry_count = 0;
    CHECK(far1_entry_count(archive, &entry_count) == TSOFILES_C_OK);
    CHECK(entry_count == 1);

    int64_t entry_index = -1;
    CHECK(far1_find_entry(archive, far1_name, (int64_t)(sizeof(far1_name) - 1), &entry_index) == TSOFILES_C_OK);

    int64_t name_size = 0;
    CHECK(far1_entry_name(archive, entry_index, &name_data, &name_size) == TSOFILES_C_OK);
    CHECK(name_size == 9);
    CHECK(name_data != NULL);
    CHECK(memcmp(name_data, far1_name, 9) == 0);
    buffer_free(name_data);
    name_data = NULL;

    int64_t data_length = 0;
    int64_t compressed_length = 0;
    int64_t data_offset = 0;
    CHECK(far1_entry_at(archive, entry_index, &data_length,
                        &compressed_length, &data_offset) == TSOFILES_C_OK);
    CHECK(data_length == 5 && compressed_length == 5 && data_offset == 16);

    int64_t entry_data_size = 0;
    CHECK(far1_entry_data(archive, entry_index, &entry_data, &entry_data_size) == TSOFILES_C_OK);
    CHECK(entry_data_size == 5);
    CHECK(entry_data != NULL);
    CHECK(entry_data[0] == 'C' && entry_data[4] == 'R');
    succeeded = true;

cleanup:
    buffer_free(name_data);
    buffer_free(entry_data);
    far1_close(archive);
    return succeeded;
}

static bool test_far3(void) {
    uint8_t far3_bytes[54] = {'F', 'A', 'R', '!', 'b', 'y', 'A', 'Z'};
    write_u32_le(far3_bytes, 8, 3);
    write_u32_le(far3_bytes, 12, 19);
    far3_bytes[16] = 'R';
    far3_bytes[17] = 'A';
    far3_bytes[18] = 'W';
    write_u32_le(far3_bytes, 19, 1);
    write_u32_le(far3_bytes, 23, 3);
    far3_bytes[27] = 3;
    write_u32_le(far3_bytes, 31, 16);
    write_u16_le(far3_bytes, 37, 7);
    write_u32_le(far3_bytes, 39, 2);
    write_u32_le(far3_bytes, 43, 7);
    const uint8_t far3_name[] = "raw.bin";
    for (size_t index = 0; index < sizeof(far3_name) - 1; index++) {
        far3_bytes[47 + index] = far3_name[index];
    }

    TSOFilesCFAR3Archive *archive = NULL;
    uint8_t *name_data = NULL;
    uint8_t *entry_data = NULL;
    bool succeeded = false;
    const int32_t status = far3_open(far3_bytes, (int64_t)sizeof(far3_bytes), &archive);
    CHECK(status == TSOFILES_C_OK);
    CHECK(archive != NULL);

    int64_t entry_count = 0;
    CHECK(far3_entry_count(archive, &entry_count) == TSOFILES_C_OK);
    CHECK(entry_count == 1);

    int64_t entry_index = -1;
    CHECK(far3_find_entry_by_name(archive, far3_name, (int64_t)(sizeof(far3_name) - 1), &entry_index) == TSOFILES_C_OK);
    CHECK(far3_find_entry_by_asset_id(archive, 7, 2, &entry_index) == TSOFILES_C_OK);

    int64_t name_size = 0;
    CHECK(far3_entry_name(archive, entry_index, &name_data, &name_size) == TSOFILES_C_OK);
    CHECK(name_size == 7);
    CHECK(name_data != NULL);
    CHECK(memcmp(name_data, far3_name, 7) == 0);
    buffer_free(name_data);
    name_data = NULL;

    uint32_t file_id = 0;
    uint32_t type_id = 0;
    uint32_t decompressed_size = 0;
    uint32_t compressed_size = 0;
    uint8_t data_type = 0;
    uint32_t data_offset = 0;
    uint8_t compression_flag = 0;
    uint8_t access_count = 0;
    CHECK(far3_entry_at(archive, entry_index, &file_id, &type_id,
                        &decompressed_size, &compressed_size, &data_type,
                        &data_offset, &compression_flag, &access_count) == TSOFILES_C_OK);
    CHECK(file_id == 7 && type_id == 2 && decompressed_size == 3);
    CHECK(compressed_size == 3 && data_offset == 16 && compression_flag == 0);

    int64_t entry_data_size = 0;
    CHECK(far3_entry_data(archive, entry_index, &entry_data, &entry_data_size) == TSOFILES_C_OK);
    CHECK(entry_data_size == 3);
    CHECK(entry_data != NULL);
    CHECK(entry_data[0] == 'R' && entry_data[2] == 'W');
    succeeded = true;

cleanup:
    buffer_free(name_data);
    buffer_free(entry_data);
    far3_close(archive);
    return succeeded;
}

int main(void) {
    if (!test_refpack() || !test_dbpf() || !test_far1() || !test_far3()) {
        return 1;
    }
    return 0;
}
