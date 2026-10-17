#include <TSOFilesC.h>

#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

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

int main(void) {
    const uint8_t compressed[] = {0x0E, 0x01, 0x61, 0x62, 0xFC, 0x00, 0x00};
    uint8_t *output = 0;
    int64_t output_size = 0;

    int32_t status = tsofiles_c_refpack_decompress(
        compressed, (int64_t)sizeof(compressed), 8, &output, &output_size);
    assert(status == TSOFILES_C_OK);
    assert(output_size == 8);
    assert(output[0] == 'a' && output[1] == 'b' && output[7] == 'b');
    tsofiles_c_buffer_free(output);

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

    TSOFilesCArchive *archive = 0;
    status = tsofiles_c_dbpf_open(dbpf, (int64_t)sizeof(dbpf), &archive);
    assert(status == TSOFILES_C_OK);
    assert(archive != 0);

    uint32_t major_version = 0;
    uint32_t minor_version = 0;
    assert(tsofiles_c_dbpf_version(archive, &major_version, &minor_version) == TSOFILES_C_OK);
    assert(major_version == 1 && minor_version == 0);

    int64_t entry_count = 0;
    assert(tsofiles_c_dbpf_entry_count(archive, &entry_count) == TSOFILES_C_OK);
    assert(entry_count == 1);

    int64_t entry_index = -1;
    assert(tsofiles_c_dbpf_find_entry(archive, 12, 0x1D07EB4B, &entry_index) == TSOFILES_C_OK);
    assert(entry_index == 0);

    uint32_t type_id = 0;
    uint32_t group_id = 0;
    uint32_t instance_id = 0;
    uint32_t file_offset = 0;
    uint32_t file_size = 0;
    assert(tsofiles_c_dbpf_entry_at(
        archive, entry_index, &type_id, &group_id, &instance_id, &file_offset, &file_size) == TSOFILES_C_OK);
    assert(type_id == 0x1D07EB4B && group_id == 0x9DBDBF89);
    assert(instance_id == 12 && file_offset == 48 && file_size == 3);

    uint8_t *entry_data = 0;
    int64_t entry_data_size = 0;
    assert(tsofiles_c_dbpf_entry_data(archive, entry_index, &entry_data, &entry_data_size) == TSOFILES_C_OK);
    assert(entry_data_size == 3);
    assert(entry_data[0] == 'S' && entry_data[1] == 'F' && entry_data[2] == 'X');
    tsofiles_c_buffer_free(entry_data);
    tsofiles_c_dbpf_close(archive);

    const uint8_t not_dbpf[] = {'N', 'O', 'P', 'E'};
    archive = 0;
    status = tsofiles_c_dbpf_open(not_dbpf, (int64_t)sizeof(not_dbpf), &archive);
    assert(status == TSOFILES_C_DBPF_NOT_ARCHIVE);
    assert(archive == 0);
    tsofiles_c_dbpf_close(archive);

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
    for (size_t i = 0; i < sizeof(far1_name) - 1; i++) {
        far1_bytes[39 + i] = far1_name[i];
    }

    TSOFilesCFAR1Archive *far1 = 0;
    status = tsofiles_c_far1_open(far1_bytes, (int64_t)sizeof(far1_bytes), 1, &far1);
    assert(status == TSOFILES_C_OK);
    int64_t far1_count = 0;
    assert(tsofiles_c_far1_entry_count(far1, &far1_count) == TSOFILES_C_OK && far1_count == 1);
    int64_t far1_index = -1;
    assert(tsofiles_c_far1_find_entry(far1, far1_name, 9, &far1_index) == TSOFILES_C_OK);
    uint8_t *far1_name_data = 0;
    int64_t far1_name_size = 0;
    assert(tsofiles_c_far1_entry_name(far1, far1_index, &far1_name_data, &far1_name_size) == TSOFILES_C_OK);
    assert(far1_name_size == 9 && memcmp(far1_name_data, far1_name, 9) == 0);
    tsofiles_c_buffer_free(far1_name_data);
    int64_t far1_data_length = 0;
    int64_t far1_compressed_length = 0;
    int64_t far1_data_offset = 0;
    assert(tsofiles_c_far1_entry_at(far1, far1_index, &far1_data_length,
                                    &far1_compressed_length, &far1_data_offset) == TSOFILES_C_OK);
    assert(far1_data_length == 5 && far1_compressed_length == 5 && far1_data_offset == 16);
    uint8_t *far1_data = 0;
    int64_t far1_data_size = 0;
    assert(tsofiles_c_far1_entry_data(far1, far1_index, &far1_data, &far1_data_size) == TSOFILES_C_OK);
    assert(far1_data_size == 5 && far1_data[0] == 'C' && far1_data[4] == 'R');
    tsofiles_c_buffer_free(far1_data);
    tsofiles_c_far1_close(far1);

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
    for (size_t i = 0; i < sizeof(far3_name) - 1; i++) {
        far3_bytes[47 + i] = far3_name[i];
    }

    TSOFilesCFAR3Archive *far3 = 0;
    status = tsofiles_c_far3_open(far3_bytes, (int64_t)sizeof(far3_bytes), &far3);
    assert(status == TSOFILES_C_OK);
    int64_t far3_count = 0;
    assert(tsofiles_c_far3_entry_count(far3, &far3_count) == TSOFILES_C_OK && far3_count == 1);
    int64_t far3_index = -1;
    assert(tsofiles_c_far3_find_entry_by_name(far3, far3_name, 7, &far3_index) == TSOFILES_C_OK);
    assert(tsofiles_c_far3_find_entry_by_asset_id(far3, 7, 2, &far3_index) == TSOFILES_C_OK);
    uint8_t *far3_name_data = 0;
    int64_t far3_name_size = 0;
    assert(tsofiles_c_far3_entry_name(far3, far3_index, &far3_name_data, &far3_name_size) == TSOFILES_C_OK);
    assert(far3_name_size == 7 && memcmp(far3_name_data, far3_name, 7) == 0);
    tsofiles_c_buffer_free(far3_name_data);
    uint32_t far3_file_id = 0;
    uint32_t far3_type_id = 0;
    uint32_t far3_decompressed_size = 0;
    uint32_t far3_compressed_size = 0;
    uint8_t far3_data_type = 0;
    uint32_t far3_data_offset = 0;
    uint8_t far3_compression_flag = 0;
    uint8_t far3_access_count = 0;
    assert(tsofiles_c_far3_entry_at(far3, far3_index, &far3_file_id, &far3_type_id,
                                    &far3_decompressed_size, &far3_compressed_size, &far3_data_type,
                                    &far3_data_offset, &far3_compression_flag, &far3_access_count) ==
           TSOFILES_C_OK);
    assert(far3_file_id == 7 && far3_type_id == 2 && far3_decompressed_size == 3);
    assert(far3_compressed_size == 3 && far3_data_offset == 16 && far3_compression_flag == 0);
    uint8_t *far3_data = 0;
    int64_t far3_data_size = 0;
    assert(tsofiles_c_far3_entry_data(far3, far3_index, &far3_data, &far3_data_size) == TSOFILES_C_OK);
    assert(far3_data_size == 3 && far3_data[0] == 'R' && far3_data[2] == 'W');
    tsofiles_c_buffer_free(far3_data);
    tsofiles_c_far3_close(far3);

    return 0;
}
